# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso_document"

RSpec.describe Metanorma::Mirror::Handlers::Structural do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::MetanormaToMirror.new(registry: registry,
                                             id_strategy: id_strategy)
  end

  def parse_preface(xml)
    Metanorma::StandardDocument::Sections::Preface.from_xml(xml)
  end

  def parse_sections(xml)
    Metanorma::StandardDocument::Sections::Sections.from_xml(xml)
  end

  describe ".preface" do
    it "returns a Preface hash" do
      el = parse_preface("<preface><foreword id='fw'><title>Foreword</title></foreword></preface>")
      result = described_class.preface(el, context: context)
      result.type.should eq("preface")
    end

    it "extracts child sections" do
      el = parse_preface("<preface><foreword id='fw'><title>Foreword</title></foreword></preface>")
      result = described_class.preface(el, context: context)
      result.content.should_not be_empty
    end
  end

  describe ".sections" do
    it "returns a Sections hash" do
      el = parse_sections("<sections><clause id='s1'><title>Scope</title></clause></sections>")
      result = described_class.sections(el, context: context)
      result.type.should eq("sections")
    end

    it "extracts child clauses" do
      el = parse_sections("<sections><clause id='s1'><title>Scope</title></clause></sections>")
      result = described_class.sections(el, context: context)
      result.content.size.should eq(1)
      result.content.first.type.should eq("clause")
    end
  end

  describe ".bibliography" do
    it "returns a Bibliography hash" do
      xml = "<bibliography><references id='refs'><p>References text</p></references></bibliography>"
      el = Metanorma::StandardDocument::Sections::BibliographySection.from_xml(xml)
      result = described_class.bibliography(el, context: context)
      result.type.should eq("bibliography")
    end
  end
end
