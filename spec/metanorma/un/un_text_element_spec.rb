# frozen_string_literal: true

require_relative "../../spec_helper"

require "metanorma/un_document"

RSpec.describe Metanorma::UnDocument::UnTextElement do
  it "allows exactly the UN grammar inline subset" do
    expect(described_class::ALLOWED_ELEMENTS).to contain_exactly(
      "em", "eref", "erefstack", "strong", "stem", "sub", "sup", "tt",
      "strike", "smallcap", "xref", "br", "link", "bookmark"
    )
  end

  it "excludes the model classes of isodoc inline productions UN forbids" do
    expect(described_class::EXCLUDED_ELEMENTS.values).to include(
      "underline", "keyword", "ruby", "hr", "pagebreak", "image",
      "index", "index-xref", "concept", "add", "del", "span"
    )
  end

  it "reports no errors for the UN fixture" do
    xml = File.read("spec/fixtures/un/ECE_AGAT_2020_INF1.presentation.xml")
    doc = Metanorma::UnDocument::Root.from_xml(xml)
    expect(described_class.validate(doc)).to be_empty
  end

  it "flags excluded elements used inline" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/un">
        <sections><clause id="_c"><p id="_p">
          <underline>u</underline><concept>c</concept><add>a</add><del>d</del>
        </p></clause></sections>
      </metanorma>
    XML
    doc = Metanorma::UnDocument::Root.from_xml(xml)
    errors = described_class.validate(doc)
    expect(errors.length).to eq(4)
    expect(errors.join).to include("underline")
    expect(errors.join).to include("concept")
    expect(errors.join).to include("add")
    expect(errors.join).to include("del")
  end

  it "ignores block-level occurrences of excluded classes" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/un">
        <sections><clause id="_c">
          <pagebreak/>
          <figure id="_f"><image id="_i" src="a.png"/></figure>
        </clause></sections>
      </metanorma>
    XML
    doc = Metanorma::UnDocument::Root.from_xml(xml)
    expect(described_class.validate(doc)).to be_empty
  end

  it "ignores span inside fmt-* presentation markup" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/un">
        <sections><clause id="_c">
          <fmt-title depth="1"><span class="fmt-element-name">Clause</span></fmt-title>
          <p id="_p">text</p>
        </clause></sections>
      </metanorma>
    XML
    doc = Metanorma::UnDocument::Root.from_xml(xml)
    expect(described_class.validate(doc)).to be_empty
  end

  describe "UnDocument::Root grammar validation" do
    it "returns no grammar errors for the UN fixture" do
      xml = File.read("spec/fixtures/un/ECE_AGAT_2020_INF1.presentation.xml")
      doc = Metanorma::UnDocument::Root.from_xml(xml)
      expect(doc.grammar_errors).to be_empty
    end

    it "returns grammar errors for a violating document" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/un" type="presentation">
          <sections><clause id="_c"><p id="_p">bad <underline>inline</underline></p></clause></sections>
        </metanorma>
      XML
      doc = Metanorma::UnDocument::Root.from_xml(xml)
      errors = doc.grammar_errors
      expect(errors.length).to eq(1)
      expect(errors.first).to include("<underline>")
    end
  end
end
