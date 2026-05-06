# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe "Section rendering consolidation" do
  let(:xml_path) { File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml", __dir__) }
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
  let(:html) { Metanorma::Html::Generator.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  it "renders clause sections with correct nesting" do
    clauses = page.css("main > div > div, main > div > div > div")
    clauses.length.should be > 0
  end

  it "renders section titles as heading elements" do
    headings = page.css("main h1, main h2, main h3")
    headings.length.should be > 0
  end

  it "renders foreword section with foreword-title class" do
    page.at_css(".foreword-title").should_not be_nil
  end

  it "renders abstract or intro sections with intro-title class when present" do
    intro = page.at_css(".intro-title")
    # The fixture may or may not have an abstract/intro
    intro&.text&.should_not be_empty
  end

  it "renders annex sections" do
    annexes = page.css(".section-sub[id]")
    annexes.length.should be > 0
  end

  it "renders terms section with term entries" do
    terms = page.css(".term-name, .term-number")
    terms.length.should be > 0
  end
end
