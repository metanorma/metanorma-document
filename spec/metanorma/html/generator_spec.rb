# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::Generator do
  let(:xml_path) { File.expand_path("../../fixtures/iso/is/document-en.presentation.xml", __dir__) }
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
  let(:html) { described_class.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  describe "document title" do
    it "renders the document title without Liquid errors" do
      html.should_not include("Liquid error")
    end

    it "renders the title in a doc-title container" do
      title_el = page.at_css(".doc-title")
      title_el.should_not be_nil
      title_el.text.should include("Cereals and pulses")
    end
  end

  describe "copyright boilerplate" do
    it "renders the email address as a link" do
      link = page.at_css('a[href="mailto:copyright@iso.org"]')
      link.should_not be_nil
      link.text.should eq("copyright@iso.org")
    end

    it "renders Published in Switzerland" do
      page.at_css("#boilerplate-place").text.should include("Published in Switzerland")
    end
  end

  describe "terms and definitions" do
    it "renders term numbers" do
      term_nums = page.css(".term-number")
      term_nums.length.should be > 0
      term_nums.first.text.should include("3")
    end

    it "renders DEPRECATED label" do
      deprecated_text = page.css("p").map(&:inner_text).find { |t| t.include?("DEPRECATED") }
      deprecated_text.should_not be_nil
    end

    it "does not duplicate domain text in term 3.6" do
      term_el = page.at_css('[id="term-_rice_-extraneous-matter"]')
      term_el.should_not be_nil
      paragraphs = term_el.css("p").map(&:inner_text)
      rice_paragraphs = paragraphs.select { |t| t.include?("<rice>") }
      rice_paragraphs.length.should eq(1)
    end
  end

  describe "bibliography cross-references" do
    it "does not double the Reference label" do
      page.css("h2, h3").map(&:text).none? { |t| t.match?(/Reference.*Reference/) }.should be(true)
    end
  end

  describe "footnotes" do
    it "renders footnotes section" do
      page.at_css(".footnotes-section").should_not be_nil
    end

    it "renders footnote back-references" do
      page.at_css(".footnote-backref").should_not be_nil
    end
  end

  describe "mailto links" do
    it "strips mailto: prefix from display text" do
      link = page.at_css('a[href="mailto:gehf@vacheequipment.fic"]')
      link.should_not be_nil
      link.text.should eq("gehf@vacheequipment.fic")
    end
  end

  describe "block elements" do
    it "renders notes with note-block class" do
      page.at_css(".note-block").should_not be_nil
    end

    it "renders examples" do
      page.at_css(".example").should_not be_nil
    end

    it "renders figures" do
      page.at_css("figure").should_not be_nil
    end

    it "renders formulas" do
      page.at_css(".formula").should_not be_nil
    end
  end
end
