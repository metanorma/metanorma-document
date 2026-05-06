# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe "HTML class name ownership" do
  let(:xml_path) { File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml", __dir__) }
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
  let(:html) { Metanorma::Html::Generator.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  # XML-originated class names that must NEVER appear in HTML output
  XML_CLASS_NAMES = %w[
    zzSTDTitle1 zzSTDTitle2 zzSTDTitle
    ForewordTitle IntroTitle
    TermNum DeprecatedTerms Terms
    Note Example
    Section3 Section3Sub
    Annex
    domain source
    termnote_label example_label
    std_publisher stdpublisher stddocNumber stddocTitle stddocPartNumber stdyear
    boldtitle nonboldtitle
    citesec citefig citetbl citeapp
    fmt-element-name fmt-obligation fmt-autonum-delim
    fmt-caption-label fmt-caption-delim
    fmt-comma fmt-conn
    fmt-label-delim
    fmt-xref-container fmt-xref-label
    smallcap
  ].freeze

  it "contains no XML-originated class names in any element" do
    all_classes = page.css("[class]").flat_map { |el| el["class"].split(/\s+/) }.uniq

    leaks = all_classes & XML_CLASS_NAMES
    leaks.should be_empty,
                 "XML classes leaked into HTML: #{leaks.inspect}"
  end

  it "uses HTML-specific class names for title text" do
    page.at_css(".title-text").should_not be_nil
  end

  it "uses HTML-specific class names for xrefs" do
    # At least one xref-section or xref-fig should exist if the document has xrefs
    xref_classes = page.css("[class*='xref-']").flat_map { |el| el["class"].split(/\s+/) }
    xref_classes.select { |c| c.start_with?("xref-") }.should_not be_empty
  end

  it "uses HTML-specific class names for bibliography references" do
    page.at_css(".ref-doc-number, .ref-publisher, .ref-year").should_not be_nil
  end

  it "uses HTML-specific class names for block elements" do
    page.at_css(".note-block").should_not be_nil
    page.at_css(".example").should_not be_nil
    page.at_css(".formula").should_not be_nil
    page.at_css("figure").should_not be_nil
  end

  it "uses term-number class instead of TermNum" do
    page.at_css(".term-number").should_not be_nil
    page.at_css(".TermNum").should be_nil
  end

  it "uses foreword-title class instead of ForewordTitle" do
    page.at_css(".foreword-title").should_not be_nil
    page.at_css(".ForewordTitle").should be_nil
  end
end
