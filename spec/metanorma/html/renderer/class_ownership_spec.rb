# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe "HTML class name ownership" do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
  let(:html) { Metanorma::Html::Generator.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  # XML-originated class names that must NEVER appear in HTML output.
  # `TermNum` is intentionally exempt: it is the isodoc convention for
  # the term-number heading (every fixture under spec/fixtures/iso/is/
  # emits `<h2 class="TermNum">`), so the renderer matches it rather
  # than inventing a parallel class.
  XML_CLASS_NAMES = %w[
    zzSTDTitle1 zzSTDTitle2 zzSTDTitle
    ForewordTitle IntroTitle
    DeprecatedTerms Terms
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
    all_classes = page.css("[class]").flat_map do |el|
      el["class"].split(/\s+/)
    end.uniq

    leaks = all_classes & XML_CLASS_NAMES
    expect(leaks).to be_empty,
                     "XML classes leaked into HTML: #{leaks.inspect}"
  end

  it "uses HTML-specific class names for title text" do
    expect(page.at_css(".title-text")).not_to be_nil
  end

  it "uses HTML-specific class names for xrefs" do
    # At least one xref-section or xref-fig should exist if the document has xrefs
    xref_classes = page.css("[class*='xref-']").flat_map do |el|
      el["class"].split(/\s+/)
    end
    expect(xref_classes.select { |c| c.start_with?("xref-") }).not_to be_empty
  end

  it "uses HTML-specific class names for bibliography references" do
    expect(page.at_css(".ref-doc-number, .ref-publisher, .ref-year")).not_to be_nil
  end

  it "uses HTML-specific class names for block elements" do
    expect(page.at_css(".note-block")).not_to be_nil
    expect(page.at_css(".example")).not_to be_nil
    expect(page.at_css(".formula")).not_to be_nil
    expect(page.at_css("figure")).not_to be_nil
  end

  it "renders term numbers as TermNum headings (isodoc convention)" do
    expect(page.at_css("h2.TermNum, h3.TermNum")).not_to be_nil
  end

  it "uses foreword-title class instead of ForewordTitle" do
    expect(page.at_css(".foreword-title")).not_to be_nil
    expect(page.at_css(".ForewordTitle")).to be_nil
  end

  it "uses ref-doc-number class instead of std-doc-number in bibliography" do
    expect(page.at_css(".ref-doc-number")).not_to be_nil
    expect(page.at_css(".std-doc-number")).to be_nil
  end

  it "uses ref-year class instead of std-year in bibliography" do
    expect(page.at_css(".ref-year")).not_to be_nil
    expect(page.at_css(".std-year")).to be_nil
  end
end
