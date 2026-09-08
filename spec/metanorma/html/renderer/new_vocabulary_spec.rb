# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"
require "metanorma/iso"

# TODO.impl/07: the grammar-coverage models must render, not parse
# into the "no renderer registered — content skipped" path.
RSpec.describe "new vocabulary rendering" do
  def render_document(body_xml)
    xml = <<~XML
            <iso-standard xmlns="https://www.metanorma.org/ns/iso" \
      type="presentation" flavor="iso">
              <bibdata type="standard"><title>Test</title></bibdata>
              <sections><clause id="_c1" obligation="normative">
                <title>Content</title>#{body_xml}</clause></sections>
            </standard-document>
    XML
    doc = Metanorma::Iso::Document::Root.from_xml(xml)
    Metanorma::Html::Generator.generate(doc)
  end

  it "renders semantic ruby as HTML ruby with its pronunciation" do
    html = render_document(
      "<p><ruby><ruby-pronunciation value=\"kanji\"/>漢字</ruby> is kanji</p>",
    )
    ruby = Nokogiri::HTML(html).at("//ruby")
    expect(ruby).not_to be_nil
    expect(ruby.text).to include("漢字")
    expect(ruby.at("rt").text).to eq("kanji")
  end

  it "renders presentation ruby (rb/rt)" do
    html = render_document(
      "<p><ruby><rb>漢字</rb><rt>かんじ</rt></ruby></p>",
    )
    ruby = Nokogiri::HTML(html).at("//ruby")
    expect(ruby.text).to include("漢字")
    expect(ruby.at("rt").text).to eq("かんじ")
  end

  it "renders columnbreak as a semantic hook" do
    html = render_document(
      "<p>First</p><columnbreak/><p>Second</p>",
    )
    expect(html).to include("column-break")
  end

  it "renders svgmap as its wrapped figure" do
    html = render_document(
      '<svgmap id="_s1"><figure id="_f1"><image src="a.svg" alt="Diagram"/>' \
      "</figure></svgmap>",
    )
    page = Nokogiri::HTML(html)
    expect(page.at("//figure")).not_to be_nil
    expect(page.at("//img")["alt"]).to eq("Diagram")
  end

  it "renders imagemap areas' wrapped figure" do
    html = render_document(
      '<imagemap id="_m1"><figure id="_f1"><image src="map.png"/></figure>' \
      '<area type="rect"><xref target="c1"/><coords x="0" y="0"/>' \
      "</area></imagemap>",
    )
    expect(Nokogiri::HTML(html).at("//figure")).not_to be_nil
  end

  it "renders annotation ruby and the image map in one document" do
    html = render_document(
      "<p><ruby><ruby-annotation value=\"abbr\"/>ISO</ruby></p>" \
      "<svgmap><figure><image src=\"a.svg\"/></figure></svgmap>",
    )
    page = Nokogiri::HTML(html)
    expect(page.at("//ruby")).not_to be_nil
    expect(page.at("//ruby/rt").text).to eq("abbr")
    expect(page.at("//figure")).not_to be_nil
  end
end
