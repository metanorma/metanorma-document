# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso/document"

RSpec.describe Metanorma::Mirror::Handlers::Inline do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_paragraph(xml)
    Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(xml)
  end

  describe "MARK_BUILDERS" do
    it "maps every inline element class to a callable builder" do
      map = described_class::MARK_BUILDERS
      map.each_value do |builder|
        expect(builder).to be_a(Method).or be_a(Proc)
        result = builder.call(nil)
        expect(result).to be_a(Metanorma::Mirror::Model::Mark)
        expect(result.type).to be_a(String)
      end
    end

    it "includes emphasis and strong mappings" do
      map = described_class::MARK_BUILDERS
      em_class = Metanorma::Document::Components::Inline::EmRawElement
      strong_class = Metanorma::Document::Components::Inline::StrongRawElement
      expect(map[em_class]).not_to be_nil
      expect(map[strong_class]).not_to be_nil

      em_mark = map[em_class].call(nil)
      expect(em_mark.type).to eq("emphasis")

      strong_mark = map[strong_class].call(nil)
      expect(strong_mark.type).to eq("strong")
    end
  end

  describe ".extract_inline" do
    it "extracts plain text from a paragraph" do
      p = parse_paragraph("<p>Hello world</p>")
      nodes = described_class.extract_inline(p, context:)
      expect(nodes.size).to eq(1)
      expect(nodes.first).to be_a(Metanorma::Mirror::Model::Text)
      expect(nodes.first.text).to eq("Hello world")
    end

    it "extracts emphasis marks" do
      p = parse_paragraph("<p>Some <em>important</em> text</p>")
      nodes = described_class.extract_inline(p, context:)
      texts = nodes.grep(Metanorma::Mirror::Model::Text)
      em_node = texts.find { |n| n.marks.any? { |m| m.type == "emphasis" } }
      expect(em_node).not_to be_nil
      expect(em_node.text).to eq("important")
    end

    it "extracts strong marks" do
      p = parse_paragraph("<p>Some <strong>bold</strong> text</p>")
      nodes = described_class.extract_inline(p, context:)
      texts = nodes.grep(Metanorma::Mirror::Model::Text)
      strong_node = texts.find { |n| n.marks.any? { |m| m.type == "strong" } }
      expect(strong_node).not_to be_nil
      expect(strong_node.text).to eq("bold")
    end

    it "extracts subscript marks" do
      p = parse_paragraph("<p>H<sub>2</sub>O</p>")
      nodes = described_class.extract_inline(p, context:)
      texts = nodes.grep(Metanorma::Mirror::Model::Text)
      sub_node = texts.find { |n| n.marks.any? { |m| m.type == "subscript" } }
      expect(sub_node).not_to be_nil
      expect(sub_node.text).to eq("2")
    end

    it "extracts superscript marks" do
      p = parse_paragraph("<p>x<sup>2</sup></p>")
      nodes = described_class.extract_inline(p, context:)
      texts = nodes.grep(Metanorma::Mirror::Model::Text)
      sup_node = texts.find { |n| n.marks.any? { |m| m.type == "superscript" } }
      expect(sup_node).not_to be_nil
      expect(sup_node.text).to eq("2")
    end

    it "extracts code (tt) marks" do
      p = parse_paragraph("<p>Use <tt>monospace</tt></p>")
      nodes = described_class.extract_inline(p, context:)
      texts = nodes.grep(Metanorma::Mirror::Model::Text)
      code_node = texts.find { |n| n.marks.any? { |m| m.type == "code" } }
      expect(code_node).not_to be_nil
      expect(code_node.text).to eq("monospace")
    end
  end

  describe ".extract_element_text" do
    it "extracts text from a simple element" do
      p = parse_paragraph("<p>Plain text</p>")
      expect(described_class.extract_element_text(p)).to eq("Plain text")
    end

    it "returns empty string for nil" do
      expect(described_class.extract_element_text(nil)).to eq("")
    end
  end

  describe ".extract_formatted_text" do
    it "extracts text from a title element" do
      xml = "<title>Simple title</title>"
      title = Metanorma::Document::Components::Inline::TitleWithAnnotationElement.from_xml(xml)
      expect(described_class.extract_formatted_text(title)).to eq("Simple title")
    end

    it "returns empty string for nil" do
      expect(described_class.extract_formatted_text(nil)).to eq("")
    end

    it "returns string representation of non-serializable" do
      expect(described_class.extract_formatted_text(42)).to eq("42")
    end
  end

  describe ".filter_empty_crossrefs" do
    it "removes text nodes with empty text and crossref marks" do
      xref = Metanorma::Mirror::Model::Mark.new(type: "xref",
                                                attrs: { "target" => "s1" })
      empty_text = Metanorma::Mirror::Model::Text.new(text: " ", marks: [xref])
      real_text = Metanorma::Mirror::Model::Text.new(text: "keep")

      result = described_class.filter_empty_crossrefs([empty_text, real_text])
      expect(result.size).to eq(1)
      expect(result.first.text).to eq("keep")
    end

    it "does not mutate the input array" do
      xref = Metanorma::Mirror::Model::Mark.new(type: "xref",
                                                attrs: { "target" => "s1" })
      empty_text = Metanorma::Mirror::Model::Text.new(text: " ", marks: [xref])
      input = [empty_text]

      described_class.filter_empty_crossrefs(input)
      expect(input.size).to eq(1)
    end

    it "keeps text nodes with non-crossref marks even if empty" do
      em = Metanorma::Mirror::Model::Mark.new(type: "emphasis")
      empty_text = Metanorma::Mirror::Model::Text.new(text: " ", marks: [em])

      result = described_class.filter_empty_crossrefs([empty_text])
      expect(result.size).to eq(1)
    end
  end

  describe ".extract_rich_html" do
    def parse_title(xml)
      Metanorma::Document::Components::Inline::TitleWithAnnotationElement.from_xml(xml)
    end

    it "extracts inline formatting correctly" do
      title = parse_title("<title>A <em>B</em> C <strong>D</strong> E</title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include("<em>B</em>")
      expect(result).to include("<strong>D</strong>")
      expect(result).to include("A ")
      expect(result).to include("C ")
      expect(result).to include(" E")
    end
  end

  describe "RichHtmlRenderer::COMPLEX_RENDERERS" do
    it "maps each element class to a callable" do
      described_class::RichHtmlRenderer::COMPLEX_RENDERERS.each_value do |renderer|
        expect(renderer).to be_a(Proc)
      end
    end
  end
end
