# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso_document"

RSpec.describe Metanorma::Mirror::Handlers::Inline do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::MetanormaToMirror.new(registry: registry,
                                             id_strategy: id_strategy)
  end

  def parse_paragraph(xml)
    Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(xml)
  end

  describe "MARK_BUILDERS" do
    it "maps every inline element class to a callable builder" do
      map = described_class::MARK_BUILDERS
      map.each_value do |builder|
        builder.should be_a(Method).or be_a(Proc)
        result = builder.call(nil)
        result.should be_a(Metanorma::Mirror::Model::Mark)
        result.type.should be_a(String)
      end
    end

    it "includes emphasis and strong mappings" do
      map = described_class::MARK_BUILDERS
      em_class = Metanorma::Document::Components::Inline::EmRawElement
      strong_class = Metanorma::Document::Components::Inline::StrongRawElement
      map[em_class].should_not be_nil
      map[strong_class].should_not be_nil

      em_mark = map[em_class].call(nil)
      em_mark.type.should eq("emphasis")

      strong_mark = map[strong_class].call(nil)
      strong_mark.type.should eq("strong")
    end
  end

  describe ".extract_inline" do
    it "extracts plain text from a paragraph" do
      p = parse_paragraph("<p>Hello world</p>")
      nodes = described_class.extract_inline(p, context:)
      nodes.size.should eq(1)
      nodes.first.should be_a(Metanorma::Mirror::Model::Text)
      nodes.first.text.should eq("Hello world")
    end

    it "extracts emphasis marks" do
      p = parse_paragraph("<p>Some <em>important</em> text</p>")
      nodes = described_class.extract_inline(p, context:)
      texts = nodes.grep(Metanorma::Mirror::Model::Text)
      em_node = texts.find { |n| n.marks.any? { |m| m.type == "emphasis" } }
      em_node.should_not be_nil
      em_node.text.should eq("important")
    end

    it "extracts strong marks" do
      p = parse_paragraph("<p>Some <strong>bold</strong> text</p>")
      nodes = described_class.extract_inline(p, context:)
      texts = nodes.grep(Metanorma::Mirror::Model::Text)
      strong_node = texts.find { |n| n.marks.any? { |m| m.type == "strong" } }
      strong_node.should_not be_nil
      strong_node.text.should eq("bold")
    end

    it "extracts subscript marks" do
      p = parse_paragraph("<p>H<sub>2</sub>O</p>")
      nodes = described_class.extract_inline(p, context:)
      texts = nodes.grep(Metanorma::Mirror::Model::Text)
      sub_node = texts.find { |n| n.marks.any? { |m| m.type == "subscript" } }
      sub_node.should_not be_nil
      sub_node.text.should eq("2")
    end

    it "extracts superscript marks" do
      p = parse_paragraph("<p>x<sup>2</sup></p>")
      nodes = described_class.extract_inline(p, context:)
      texts = nodes.grep(Metanorma::Mirror::Model::Text)
      sup_node = texts.find { |n| n.marks.any? { |m| m.type == "superscript" } }
      sup_node.should_not be_nil
      sup_node.text.should eq("2")
    end

    it "extracts code (tt) marks" do
      p = parse_paragraph("<p>Use <tt>monospace</tt></p>")
      nodes = described_class.extract_inline(p, context:)
      texts = nodes.grep(Metanorma::Mirror::Model::Text)
      code_node = texts.find { |n| n.marks.any? { |m| m.type == "code" } }
      code_node.should_not be_nil
      code_node.text.should eq("monospace")
    end
  end

  describe ".extract_element_text" do
    it "extracts text from a simple element" do
      p = parse_paragraph("<p>Plain text</p>")
      described_class.extract_element_text(p).should eq("Plain text")
    end

    it "returns empty string for nil" do
      described_class.extract_element_text(nil).should eq("")
    end
  end

  describe ".extract_formatted_text" do
    it "extracts text from a title element" do
      xml = "<title>Simple title</title>"
      title = Metanorma::Document::Components::Inline::TitleWithAnnotationElement.from_xml(xml)
      described_class.extract_formatted_text(title).should eq("Simple title")
    end

    it "returns empty string for nil" do
      described_class.extract_formatted_text(nil).should eq("")
    end

    it "returns string representation of non-serializable" do
      described_class.extract_formatted_text(42).should eq("42")
    end
  end

  describe ".filter_empty_crossrefs" do
    it "removes text nodes with empty text and crossref marks" do
      xref = Metanorma::Mirror::Model::Mark.new(type: "xref", attrs: { "target" => "s1" })
      empty_text = Metanorma::Mirror::Model::Text.new(text: " ", marks: [xref])
      real_text = Metanorma::Mirror::Model::Text.new(text: "keep")

      result = described_class.filter_empty_crossrefs([empty_text, real_text])
      result.size.should eq(1)
      result.first.text.should eq("keep")
    end

    it "does not mutate the input array" do
      xref = Metanorma::Mirror::Model::Mark.new(type: "xref", attrs: { "target" => "s1" })
      empty_text = Metanorma::Mirror::Model::Text.new(text: " ", marks: [xref])
      input = [empty_text]

      described_class.filter_empty_crossrefs(input)
      input.size.should eq(1)
    end

    it "keeps text nodes with non-crossref marks even if empty" do
      em = Metanorma::Mirror::Model::Mark.new(type: "emphasis")
      empty_text = Metanorma::Mirror::Model::Text.new(text: " ", marks: [em])

      result = described_class.filter_empty_crossrefs([empty_text])
      result.size.should eq(1)
    end
  end

  describe ".extract_rich_html" do
    def parse_title(xml)
      Metanorma::Document::Components::Inline::TitleWithAnnotationElement.from_xml(xml)
    end

    it "extracts inline formatting correctly" do
      title = parse_title("<title>A <em>B</em> C <strong>D</strong> E</title>")
      result = described_class.extract_rich_html(title)
      result.should include("<em>B</em>")
      result.should include("<strong>D</strong>")
      result.should include("A ")
      result.should include("C ")
      result.should include(" E")
    end
  end

  describe "RichHtmlRenderer::RENDERERS" do
    it "maps each element class to a valid tag or method" do
      described_class::RichHtmlRenderer::RENDERERS.each_value do |renderer|
        if renderer.is_a?(Symbol)
          described_class::RichHtmlRenderer.method(renderer).should_not be_nil
        else
          renderer.should be_a(String)
        end
      end
    end
  end
end
