# frozen_string_literal: true

require "spec_helper"

# Grammar-coverage models for the ruby / svgmap / imagemap /
# columnbreak vocabulary (#2: enumerate classes to map all elements
# from the standoc grammars).
RSpec.describe "grammar coverage gap models" do
  describe Metanorma::Document::Components::TextElements::RubyElement do
    it "parses the semantic form: annotation first, then annotated text" do
      ruby = described_class.from_xml(
        '<ruby><ruby-pronunciation value="kanji" language="ja"/>漢字</ruby>',
      )

      expect(ruby.pronunciation.value).to eq("kanji")
      expect(ruby.pronunciation.language).to eq("ja")
      expect(ruby.text).to eq(["漢字"])
    end

    it "parses nested ruby in the annotated text" do
      ruby = described_class.from_xml(
        '<ruby><ruby-annotation value="info"/><ruby>' \
        '<ruby-pronunciation value="inner"/>nested</ruby></ruby>',
      )

      expect(ruby.annotation.value).to eq("info")
      expect(ruby.ruby.first.pronunciation.value).to eq("inner")
      expect(ruby.ruby.first.text).to eq(["nested"])
    end

    it "parses the presentation form: rb base text and rt annotation" do
      ruby = described_class.from_xml(
        "<ruby><rb>漢字</rb><rt>かんじ</rt></ruby>",
      )

      expect(ruby.ruby_base.text).to eq(["漢字"])
      expect(ruby.ruby_text).to eq(["かんじ"])
    end

    it "round-trips the semantic form" do
      xml = '<ruby><ruby-pronunciation value="kanji"/>漢字</ruby>'
      expect(described_class.from_xml(xml).to_xml)
        .to be_xml_equivalent_to(xml)
    end
  end

  describe Metanorma::Document::Components::Inline::ColumnbreakElement do
    it "round-trips the empty element" do
      expect(described_class.from_xml("<columnbreak/>").to_xml)
        .to be_xml_equivalent_to("<columnbreak/>")
    end
  end

  describe Metanorma::Document::Components::AncillaryBlocks::SvgmapElement do
    it "parses the figure and the link-overwriting targets" do
      svgmap = described_class.from_xml(
        '<svgmap id="_s1"><figure id="_f1"><image src="a.svg"/></figure>' \
        '<target href="B"><xref target="clause-2"/></target>' \
        '<target href="C"><eref bibitemid="ISO7301" citeas="ISO 7301"/>' \
        "</target></svgmap>",
      )

      expect(svgmap.id).to eq("_s1")
      expect(svgmap.figure.first.id).to eq("_f1")
      expect(svgmap.target.first.href).to eq("B")
      expect(svgmap.target.first.xref.target).to eq("clause-2")
      expect(svgmap.target.last.eref.citeas).to eq("ISO 7301")
    end
  end

  describe Metanorma::Document::Components::AncillaryBlocks::ImagemapElement do
    it "parses areas with shape, link, coordinates, and radius" do
      imagemap = described_class.from_xml(
        '<imagemap id="_m1"><figure id="_f1"><image src="a.png"/></figure>' \
        '<area type="circle"><xref target="clause-2"/>' \
        '<coords x="1.5" y="2.5"/><radius x="3.0" y="4.0"/></area>' \
        '<area type="poly"><link target="https://example.com"/>' \
        '<coords x="0" y="0"/><coords x="1" y="1"/></area></imagemap>',
      )

      expect(imagemap.id).to eq("_m1")
      circle = imagemap.area.first
      expect(circle.area_type).to eq("circle")
      expect(circle.xref.target).to eq("clause-2")
      expect(circle.coords.first.x).to eq(1.5)
      expect(circle.radius.y).to eq(4.0)
      poly = imagemap.area.last
      expect(poly.link.target).to eq("https://example.com")
      expect(poly.coords.size).to eq(2)
    end
  end

  describe "parent wiring" do
    it "parses ruby inside paragraphs (the inline-content containers)" do
      para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(
        "<p><ruby><ruby-pronunciation value=\"tokyo\"/>東京</ruby> is a city</p>",
      )

      expect(para.ruby.first.pronunciation.value).to eq("tokyo")
      expect(Metanorma::Document::PlainText.call(para)).to eq("東京 is a city")
    end

    it "parses ruby inside table cells" do
      cell = Metanorma::Document::Components::Tables::TextTableCell.from_xml(
        "<td><ruby><rb>漢字</rb><rt>かんじ</rt></ruby></td>",
      )

      expect(cell.ruby.first.ruby_base.text).to eq(["漢字"])
      expect(Metanorma::Document::PlainText.call(cell)).to eq("漢字")
    end
  end
end
