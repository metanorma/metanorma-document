# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/xml_highlighter"

RSpec.describe Metanorma::Html::XmlHighlighter do
  # Spans off, entities back to characters: the emitted html must
  # decode to exactly the input text.
  def decoded(html)
    html.gsub(%r{</?span[^>]*>}, "")
      .gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&")
  end

  it "wraps tag names, attribute names and values" do
    html = described_class.highlight(
      %(<SeaIce gml:id="ID1">), lang: "xml",
    )
    expect(html).to include(%(<span class="nt">SeaIce</span>))
    expect(html).to include(%(<span class="na">gml:id</span>))
    expect(html).to include(%(<span class="s">"ID1"</span>))
    expect(decoded(html)).to eq(%(<SeaIce gml:id="ID1">))
  end

  it "escapes content outside tags" do
    html = described_class.highlight(
      "<snowDepth>10</snowDepth>", lang: "xml",
    )
    expect(html).to include(%(<span class="nt">snowDepth</span>))
    expect(html).not_to include("<snowDepth")
    expect(decoded(html)).to eq("<snowDepth>10</snowDepth>")
  end

  it "keeps self-closing and closing markers" do
    html = described_class.highlight("</gml:exterior>", lang: "xml")
    expect(html).to start_with("&lt;/")
    expect(html).to end_with("&gt;")
    expect(decoded(html)).to eq("</gml:exterior>")

    html = described_class.highlight("<br/>", lang: "xml")
    expect(decoded(html)).to eq("<br/>")
  end

  it "highlights comments as a whole" do
    html = described_class.highlight("a<!-- note -->b", lang: "xml")
    expect(html).to include('<span class="c">!-- note --</span>')
    expect(decoded(html)).to eq("a<!-- note -->b")
  end

  it "tolerates unterminated tags" do
    html = described_class.highlight("<SeaIce", lang: "xml")
    expect(html).to include(%(<span class="nt">SeaIce</span>))
    expect(decoded(html)).to eq("<SeaIce")
  end

  it "does not treat > inside attribute values as a tag end" do
    source = %(<a title="x > y" href="#">t</a>)
    html = described_class.highlight(source, lang: "xml")
    expect(decoded(html)).to eq(source)
    expect(html.scan(%(<span class="nt">a</span>)).length).to eq(2)
  end

  it "escapes ampersands in text and values" do
    html = described_class.highlight("<t a='&'>x & y</t>", lang: "xml")
    expect(html).to include("&amp;")
    expect(decoded(html)).to eq("<t a='&'>x & y</t>")
  end

  it "passes through non-XML languages unhighlighted but escaped" do
    html = described_class.highlight("<tag>", lang: "ruby")
    expect(html).to eq("&lt;tag&gt;")
  end

  it "tolerates nil text" do
    expect(described_class.highlight(nil, lang: "xml")).to eq("")
  end
end
