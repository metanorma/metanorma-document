# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::Drops do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::Iso::Document::Root.from_xml(xml) }
  let(:html) { Metanorma::Html::Generator.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  describe "NoteDrop" do
    it "renders notes with note-block class" do
      expect(page.at_css(".note-block")).not_to be_nil
    end

    it "renders note label" do
      note = page.at_css(".note-block .note-label")
      expect(note).not_to be_nil
      expect(note.text).to include("NOTE")
    end

    it "places the note label inside the first <p> of the note" do
      first_p = page.at_css(".note-block > p:first-child")
      expect(first_p).not_to be_nil
      first_child = first_p.children.find do |n|
        n.is_a?(Nokogiri::XML::Element)
      end
      expect(first_child).not_to be_nil
      expect(first_child["class"])
        .to(satisfy { |c| %w[note-label term-note-label].include?(c) })
    end
  end

  describe "ExampleDrop" do
    it "renders examples with example class" do
      expect(page.at_css(".example")).not_to be_nil
    end

    it "renders example label" do
      example = page.at_css(".example .example-label")
      expect(example).not_to be_nil
      expect(example.text).to include("EXAMPLE")
    end

    it "places the example label inside the first <p> of the example" do
      first_p = page.at_css(".example > p:first-child")
      expect(first_p).not_to be_nil
      first_child = first_p.children.first
      expect(first_child).to be_a(Nokogiri::XML::Element)
      expect(first_child["class"]).to eq("example-label")
    end
  end

  describe "SourcecodeDrop" do
    it "renders sourcecode blocks" do
      expect(page.at_css(".sourcecode")).not_to be_nil
    end

    it "wraps code in pre/code tags" do
      expect(page.at_css(".sourcecode pre code")).not_to be_nil
    end
  end

  describe "FormulaDrop" do
    it "renders formula blocks" do
      expect(page.at_css(".formula")).not_to be_nil
    end

    it "renders formula content" do
      formulas = page.css(".formula")
      expect(formulas.length).to be > 0
      # Formulas contain either math elements or where clauses
      expect(formulas.any? do |f|
        f.inner_html.include?("formula-where")
      end).to be(true)
    end
  end

  describe "FigureDrop" do
    it "renders figure elements" do
      expect(page.at_css("figure")).not_to be_nil
    end

    it "renders figure caption" do
      expect(page.at_css("figure figcaption")).not_to be_nil
    end
  end

  describe "FootnoteDrop" do
    it "renders footnotes section with numbered entries" do
      footnotes = page.css(".footnotes-section .footnote")
      expect(footnotes.length).to be > 0
    end

    it "renders footnote back-references" do
      expect(page.at_css(".footnote-backref")).not_to be_nil
    end
  end
end
