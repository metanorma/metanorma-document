# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/document"

# Mirror coverage for the grammar-gap models (#2 follow-through): the
# seed registrations carry ruby/svgmap/imagemap into the mirror JSON.
RSpec.describe "new vocabulary in the mirror projection" do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  describe Metanorma::Mirror::Handlers::Svgmap do
    it "emits the figure and the href-to-anchor link map" do
      el = Metanorma::Document::Components::AncillaryBlocks::SvgmapElement.from_xml(
        '<svgmap id="_s1"><figure id="_f1"><image src="a.svg"/></figure>' \
        '<target href="B"><xref target="clause-2"/></target></svgmap>',
      )

      result = described_class.call(el, context: context)
      expect(result.type).to eq("svgmap")
      expect(result.attrs["id"]).to eq("_s1")
      expect(result.attrs["links"]).to eq("B" => "clause-2")
      expect(result.content.map(&:type)).to include("figure")
    end

    it "resolves eref targets by bibitemid" do
      el = Metanorma::Document::Components::AncillaryBlocks::SvgmapElement.from_xml(
        '<svgmap><figure><image src="a.svg"/></figure>' \
        '<target href="E"><eref bibitemid="ISO7301" citeas="ISO 7301"/></target>' \
        "</svgmap>",
      )

      result = described_class.call(el, context: context)
      expect(result.attrs["links"]).to eq("E" => "ISO7301")
    end
  end

  describe Metanorma::Mirror::Handlers::Imagemap do
    it "emits the figure and the area geometry" do
      el = Metanorma::Document::Components::AncillaryBlocks::ImagemapElement.from_xml(
        '<imagemap id="_m1"><figure><image src="a.png"/></figure>' \
        '<area type="circle"><xref target="clause-2"/>' \
        '<coords x="1.5" y="2.5"/><radius x="3.0" y="4.0"/></area></imagemap>',
      )

      result = described_class.call(el, context: context)
      expect(result.type).to eq("imagemap")
      area = result.attrs["areas"].first
      expect(area[:type]).to eq("circle")
      expect(area[:target]).to eq("clause-2")
      expect(area[:coords]).to eq([[1.5, 2.5]])
      expect(area[:radius]).to eq([3.0, 4.0])
      expect(result.content.map(&:type)).to include("figure")
    end
  end

  describe "ruby marks" do
    it "carries the pronunciation as mark attrs over the base text" do
      para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(
        "<p><ruby><ruby-pronunciation value=\"kanji\"/>漢字</ruby> is kanji</p>",
      )

      text = Metanorma::Mirror::Handlers::Inline.extract_inline(para, context: context)
      node = text.find { |n| n.marks.any? { |m| m.type == "ruby" } }
      expect(node).not_to be_nil
      expect(node.text).to eq("漢字")
      mark = node.marks.find { |m| m.type == "ruby" }
      expect(mark.attrs["pronunciation"]).to eq("kanji")
    end

    it "carries the presentation form rt as ruby_text" do
      para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(
        "<p><ruby><rb>漢字</rb><rt>かんじ</rt></ruby></p>",
      )

      text = Metanorma::Mirror::Handlers::Inline.extract_inline(para, context: context)
      node = text.find { |n| n.marks.any? { |m| m.type == "ruby" } }
      expect(node).not_to be_nil
      expect(node.marks.find { |m| m.type == "ruby" }.attrs["ruby_text"])
        .to eq("かんじ")
    end
  end
end
