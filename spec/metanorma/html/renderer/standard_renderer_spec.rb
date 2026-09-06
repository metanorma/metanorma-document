# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::StandardRenderer do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::Iso::Document::Root.from_xml(xml) }
  let(:html) { Metanorma::Html::Generator.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  describe "#render_section" do
    it "renders clause sections with nested headings" do
      headings = page.css("main div[id] h2, main div[id] h3")
      expect(headings.length).to be > 0
    end

    it "renders terms sections with TermNum headings" do
      expect(page.at_css(".TermNum")).not_to be_nil
    end

    it "renders foreword with foreword-title class" do
      expect(page.at_css(".foreword-title")).not_to be_nil
    end

    it "does not emit raw XML class names in sections" do
      xml_classes = %w[ForewordTitle IntroTitle Section3 Annex]
      all_classes = page.css("[class]").flat_map do |el|
        el["class"].split(/\s+/)
      end.uniq
      expect(all_classes & xml_classes).to be_empty
    end

    it "renders all main sections inside main element" do
      main = page.at_css("main")
      expect(main).not_to be_nil
      expect(main.inner_html.length).to be > 100
    end
  end
end
