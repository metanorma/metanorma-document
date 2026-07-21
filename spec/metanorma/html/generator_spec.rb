# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::Generator do
  let(:xml_path) do
    File.expand_path("../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
  let(:html) { described_class.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  describe "document title" do
    it "renders the document title without Liquid errors" do
      expect(html).not_to include("Liquid error")
    end

    it "renders the title in a doc-title container" do
      title_el = page.at_css(".doc-title")
      expect(title_el).not_to be_nil
      expect(title_el.text).to include("Cereals and pulses")
    end
  end

  describe "copyright boilerplate" do
    it "renders the email address as a link" do
      link = page.at_css('a[href="mailto:copyright@iso.org"]')
      expect(link).not_to be_nil
      expect(link.text).to eq("copyright@iso.org")
    end

    it "renders Published in Switzerland" do
      expect(page.at_css("#boilerplate-place").text).to include("Published in Switzerland")
    end
  end

  describe "terms and definitions" do
    it "renders term numbers as TermNum headings" do
      term_nums = page.css(".TermNum")
      expect(term_nums.length).to be > 0
      expect(term_nums.first.text).to include("3")
    end

    it "renders DEPRECATED label" do
      deprecated_text = page.css("p").map(&:inner_text).find do |t|
        t.include?("DEPRECATED")
      end
      expect(deprecated_text).not_to be_nil
    end

    it "does not duplicate domain text in term 3.6" do
      term_el = page.at_css('[id="term-_rice_-extraneous-matter"]')
      expect(term_el).not_to be_nil
      paragraphs = term_el.css("p").map(&:inner_text)
      rice_paragraphs = paragraphs.select { |t| t.include?("<rice>") }
      expect(rice_paragraphs.length).to eq(1)
    end
  end

  describe "bibliography cross-references" do
    it "does not double the Reference label" do
      expect(page.css("h2, h3").map(&:text).none? do |t|
        t.match?(/Reference.*Reference/)
      end).to be(true)
    end
  end

  describe "footnotes" do
    it "renders footnotes section" do
      expect(page.at_css(".footnotes-section")).not_to be_nil
    end

    it "renders footnote back-references" do
      expect(page.at_css(".footnote-backref")).not_to be_nil
    end
  end

  describe "mailto links" do
    it "strips mailto: prefix from display text" do
      link = page.at_css('a[href="mailto:gehf@vacheequipment.fic"]')
      expect(link).not_to be_nil
      expect(link.text).to eq("gehf@vacheequipment.fic")
    end
  end

  describe "block elements" do
    it "renders notes with note-block class" do
      expect(page.at_css(".note-block")).not_to be_nil
    end

    it "renders examples" do
      expect(page.at_css(".example")).not_to be_nil
    end

    it "renders figures" do
      expect(page.at_css("figure")).not_to be_nil
    end

    it "renders formulas" do
      expect(page.at_css(".formula")).not_to be_nil
    end
  end
end
