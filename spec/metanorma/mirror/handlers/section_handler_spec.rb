# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso_document"

RSpec.describe Metanorma::Mirror::Handlers::Section do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                             id_strategy: id_strategy)
  end

  def parse_clause(xml)
    Metanorma::StandardDocument::Sections::ClauseSection.from_xml(xml)
  end

  def parse_annex(xml)
    Metanorma::StandardDocument::Sections::AnnexSection.from_xml(xml)
  end

  describe ".clause" do
    it "returns a Clause hash" do
      el = parse_clause("<clause id='c1'><title>Scope</title><p>Text</p></clause>")
      result = described_class.clause(el, context: context)
      result.type.should eq("clause")
    end

    it "extracts id and title" do
      el = parse_clause("<clause id='c1'><title>Scope</title></clause>")
      result = described_class.clause(el, context: context)
      result.attrs["id"].should eq("c1")
    end

    it "extracts title text" do
      el = parse_clause("<clause id='c1'><title>Scope</title></clause>")
      result = described_class.clause(el, context: context)
      result.attrs["title"].should eq("Scope")
    end

    it "extracts block content from mixed_content" do
      el = parse_clause("<clause id='c1'><p>Para 1</p><p>Para 2</p></clause>")
      result = described_class.clause(el, context: context)
      result.content.size.should eq(2)
      result.content.each { |c| c.type.should eq("paragraph") }
    end
  end

  describe ".annex" do
    it "returns an Annex hash" do
      el = parse_annex("<annex id='a1'><title>Annex A</title><p>Text</p></annex>")
      result = described_class.annex(el, context: context)
      result.type.should eq("annex")
    end

    it "extracts annex-specific attributes" do
      el = parse_annex("<annex id='a1' language='en'><title>Notes</title></annex>")
      result = described_class.annex(el, context: context)
      result.attrs["language"].should eq("en")
    end
  end

  describe ".floating_title" do
    it "returns a FloatingTitle hash" do
      el = Metanorma::StandardDocument::Sections::FloatingTitle.from_xml(
        "<floating-title depth='3'>Subtitle</floating-title>",
      )
      result = described_class.floating_title(el, context: context)
      result.type.should eq("floating_title")
    end

    it "extracts depth" do
      el = Metanorma::StandardDocument::Sections::FloatingTitle.from_xml(
        "<floating-title depth='3'>Subtitle</floating-title>",
      )
      result = described_class.floating_title(el, context: context)
      result.attrs["depth"].should eq(3)
    end
  end

  describe ".extract_title" do
    it "returns nil when no title" do
      el = parse_clause("<clause id='c1'></clause>")
      described_class.extract_title(el).should be_nil
    end

    it "extracts string title" do
      el = parse_clause("<clause id='c1'><title>Simple</title></clause>")
      described_class.extract_title(el).should eq("Simple")
    end
  end

  describe ".section_attrs" do
    it "compacts nil values" do
      el = parse_clause("<clause id='c1'><title>T</title></clause>")
      attrs = described_class.section_attrs(el, context: context)
      attrs.should_not have_key(:number)
      attrs.should_not have_key(:obligation)
    end
  end

  describe ".content_section" do
    it "returns a content_section hash" do
      el = Metanorma::StandardDocument::Sections::ContentSection.from_xml(
        "<foreword id='fw'><title>Foreword</title><p>Text</p></foreword>",
      )
      result = described_class.content_section(el, context: context)
      result.type.should eq("content_section")
      result.attrs["id"].should eq("fw")
    end
  end

  describe ".terms" do
    it "returns a terms hash" do
      el = Metanorma::StandardDocument::Sections::TermsSection.from_xml(
        "<terms id='terms'><title>Terms</title></terms>",
      )
      result = described_class.terms(el, context: context)
      result.type.should eq("terms")
      result.attrs["id"].should eq("terms")
    end
  end

  describe ".definitions" do
    it "returns a definitions hash" do
      el = Metanorma::StandardDocument::Sections::DefinitionSection.from_xml(
        "<definitions id='defs'><title>Definitions</title></definitions>",
      )
      result = described_class.definitions(el, context: context)
      result.type.should eq("definitions")
      result.attrs["id"].should eq("defs")
    end
  end

  describe ".references" do
    it "returns a references hash" do
      el = Metanorma::StandardDocument::Sections::StandardReferencesSection.from_xml(
        "<references id='refs' normative='true'><p>The following documents</p></references>",
      )
      result = described_class.references(el, context: context)
      result.type.should eq("references")
      result.attrs["id"].should eq("refs")
    end
  end
end
