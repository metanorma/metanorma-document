# frozen_string_literal: true

require "spec_helper"
load File.expand_path("../../script/content_parity.rb", __dir__)

RSpec.describe ContentParity do
  let(:legacy) do
    <<~HTML
      <body><div class="TOC"><p>Contents</p></div>
      <h1>1  Scope</h1><p>Alpha text. <a href="#c1">Clause 4</a></p>
      <div class="Note"><p>NOTE  Beta note</p></div>
      <table><tr><td>Cell</td></tr></table>
      <ul><li><p>Item one</p></li></ul></body>
    HTML
  end

  it "reports nothing for identical content in different markup" do
    new_html = <<~HTML
      <body><nav><p>Contents</p></nav><h1>1 Scope</h1>
      <p>Alpha text. <a href="#c1">Clause 4</a></p>
      <div class="note-block"><p>NOTE Beta note</p></div>
      <table><tr><td>Cell</td></tr></table><ul><li>Item one</li></ul></body>
    HTML
    r = described_class.compare(legacy, new_html)
    expect([r["missing_blocks"], r["lost_kinds"], r["lost_link_texts"]])
      .to eq([[], [], {}])
  end

  it "reports lost text, headings, tables, notes and cross-references" do
    new_html = "<body><p>Alpha text.</p></body>"
    r = described_class.compare(legacy, new_html)
    expect(r["missing_headings"].map { |b| b["text"] }).to eq(["1 Scope"])
    expect(r["lost_kinds"]).to include("tables", "notes", "headings",
                                       "cross-references")
    expect(r["missing_blocks"].map { |b| b["text"] }).to include("Cell")
  end

  it "does not count generated navigation as content" do
    r = described_class.compare("<body><nav><p>Only nav</p></nav></body>",
                                "<body></body>")
    expect(r["legacy_blocks"]).to eq(0)
  end

  it "turns render failures into data" do
    r = described_class.run_case("nonexistent-flavor", "x", xml: __FILE__)
    expect(r["status"]).to include("failed")
  end

  it "builds a markdown table" do
    md = described_class.markdown([{ "flavor" => "f", "case" => "c",
                                     "status" => "new-failed",
                                     "error" => "boom" }])
    expect(md).to include("| f | c | new-failed | boom")
  end

  it "matches paragraph text split by an inline footnote popup" do
    legacy_html = "<body><p>Text.<sup>1</sup> More text.</p></body>"
    new_html = '<body><p>Text.<span class="fn-marker"><sup>1</sup>' \
               '<span class="fn-popup">Note body</span></span> More ' \
               "text.</p></body>"
    expect(described_class.compare(legacy_html, new_html)["missing_blocks"])
      .to eq([])
  end

  it "still requires footnote body text to be present" do
    legacy_html = "<body><p>Footnote body text</p></body>"
    result = described_class.compare(legacy_html, "<body></body>")
    expect(result["missing_blocks"].size).to eq(1)
  end

  it "counts terms by dfn and ignores bibliography layout tables" do
    legacy_html = '<body><p class="TermNum"></p><p><dfn>t</dfn></p>' \
                  '<table class="biblio"><tr><td>[1]</td></tr></table></body>'
    r = described_class.compare(legacy_html, "<body><p><dfn>t</dfn></p></body>")
    expect(r["lost_kinds"]).to eq([])
  end
end
