# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::Drops do
  let(:xml_path) { File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml", __dir__) }
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
  let(:html) { Metanorma::Html::Generator.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  describe "NoteDrop" do
    it "renders notes with note-block class" do
      page.at_css(".note-block").should_not be_nil
    end

    it "renders note label" do
      note = page.at_css(".note-block .note-label")
      note.should_not be_nil
      note.text.should include("NOTE")
    end
  end

  describe "ExampleDrop" do
    it "renders examples with example class" do
      page.at_css(".example").should_not be_nil
    end

    it "renders example label" do
      example = page.at_css(".example .example-label")
      example.should_not be_nil
      example.text.should include("EXAMPLE")
    end
  end

  describe "SourcecodeDrop" do
    it "renders sourcecode blocks" do
      page.at_css(".sourcecode").should_not be_nil
    end

    it "wraps code in pre/code tags" do
      page.at_css(".sourcecode pre code").should_not be_nil
    end
  end

  describe "FormulaDrop" do
    it "renders formula blocks" do
      page.at_css(".formula").should_not be_nil
    end

    it "renders formula content" do
      formulas = page.css(".formula")
      formulas.length.should be > 0
      # Formulas contain either math elements or where clauses
      formulas.any? { |f| f.inner_html.include?("formula-where") }.should be(true)
    end
  end

  describe "FigureDrop" do
    it "renders figure elements" do
      page.at_css("figure").should_not be_nil
    end

    it "renders figure caption" do
      page.at_css("figure figcaption").should_not be_nil
    end
  end

  describe "FootnoteDrop" do
    it "renders footnotes section with numbered entries" do
      footnotes = page.css(".footnotes-section .footnote")
      footnotes.length.should be > 0
    end

    it "renders footnote back-references" do
      page.at_css(".footnote-backref").should_not be_nil
    end
  end
end
