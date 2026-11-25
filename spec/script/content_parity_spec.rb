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
end
