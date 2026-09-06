# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso/document"

RSpec.describe Metanorma::Mirror::Handlers::Term do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_term(xml)
    Metanorma::Iso::Document::Terms::IsoTerm.from_xml(xml)
  end

  describe ".call" do
    it "returns a Term hash" do
      xml = <<~XML
        <term id='t1'>
          <preferred><expression><name>test term</name></expression></preferred>
          <definition><verbal-definition><p>A definition</p></verbal-definition></definition>
        </term>
      XML
      el = parse_term(xml)
      result = described_class.call(el, context: context)
      expect(result.type).to eq("term")
    end

    it "extracts term id" do
      xml = <<~XML
        <term id='term-alpha'>
          <preferred><expression><name>alpha</name></expression></preferred>
        </term>
      XML
      el = parse_term(xml)
      result = described_class.call(el, context: context)
      expect(result.attrs["id"]).to eq("term-alpha")
    end
  end
end
