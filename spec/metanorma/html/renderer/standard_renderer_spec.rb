# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::StandardRenderer do
  let(:xml_path) { File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml", __dir__) }
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
  let(:html) { Metanorma::Html::Generator.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  describe "#render_section" do
    it "renders clause sections with nested headings" do
      headings = page.css("main div[id] h2, main div[id] h3")
      headings.length.should be > 0
    end

    it "renders terms sections with term-number entries" do
      page.at_css(".term-number").should_not be_nil
    end

    it "renders foreword with foreword-title class" do
      page.at_css(".foreword-title").should_not be_nil
    end

    it "does not emit raw XML class names in sections" do
      xml_classes = %w[ForewordTitle IntroTitle Section3 Annex]
      all_classes = page.css("[class]").flat_map { |el| el["class"].split(/\s+/) }.uniq
      (all_classes & xml_classes).should be_empty
    end

    it "renders all main sections inside main element" do
      main = page.at_css("main")
      main.should_not be_nil
      main.inner_html.length.should be > 100
    end
  end
end
