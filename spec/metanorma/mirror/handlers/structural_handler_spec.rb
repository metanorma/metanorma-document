# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso/document"

RSpec.describe Metanorma::Mirror::Handlers::Structural do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_preface(xml)
    Metanorma::Standoc::Document::Sections::Preface.from_xml(xml)
  end

  def parse_sections(xml)
    Metanorma::Standoc::Document::Sections::Sections.from_xml(xml)
  end

  describe ".preface" do
    it "returns a Preface hash" do
      el = parse_preface("<preface><foreword id='fw'><title>Foreword</title></foreword></preface>")
      result = described_class.preface(el, context: context)
      expect(result.type).to eq("preface")
    end

    it "extracts child sections" do
      el = parse_preface("<preface><foreword id='fw'><title>Foreword</title></foreword></preface>")
      result = described_class.preface(el, context: context)
      expect(result.content).not_to be_empty
    end
  end

  describe ".sections" do
    it "returns a Sections hash" do
      el = parse_sections("<sections><clause id='s1'><title>Scope</title></clause></sections>")
      result = described_class.sections(el, context: context)
      expect(result.type).to eq("sections")
    end

    it "extracts child clauses" do
      el = parse_sections("<sections><clause id='s1'><title>Scope</title></clause></sections>")
      result = described_class.sections(el, context: context)
      expect(result.content.size).to eq(1)
      expect(result.content.first.type).to eq("clause")
    end
  end

  describe ".bibliography" do
    it "returns a Bibliography hash" do
      xml = "<bibliography><references id='refs'><p>References text</p></references></bibliography>"
      el = Metanorma::Standoc::Document::Sections::BibliographySection.from_xml(xml)
      result = described_class.bibliography(el, context: context)
      expect(result.type).to eq("bibliography")
    end
  end
end
