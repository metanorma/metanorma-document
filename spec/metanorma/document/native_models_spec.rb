# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe Metanorma::Document::NativeModels do
  let(:semantic_xml) do
    File.read(File.expand_path("../../fixtures/iso/is/document-en.xml",
                               __dir__), encoding: "utf-8")
  end
  let(:model) { Metanorma::Iso::Document::Root.from_xml(semantic_xml) }

  describe ".glossarist_concepts" do
    it "exports term entries as native Glossarist::Concept objects" do
      concepts = described_class.glossarist_concepts(model)
      expect(concepts).not_to be_empty
      expect(concepts).to all(be_a(Glossarist::Concept))

      paddy = concepts.find do |c|
        c.data.terms.first.designation == "paddy"
      end
      expect(paddy).not_to be_nil
      expect(paddy.data.definition.first.content)
        .to eq("rice retaining its husk after threshing")
      expect(paddy.data.language_code).to eq("eng")

      native = JSON.parse(paddy.to_json)
      expect(native.dig("data", "terms", 0, "type")).to eq("expression")
      expect(native.dig("data", "sources", 0, "origin", "ref", "source"))
        .to eq("ISO 7301:2011")
    end

    it "is deterministic across calls" do
      a = described_class.glossarist_concepts(model).map(&:to_json)
      b = described_class.glossarist_concepts(model).map(&:to_json)
      expect(a).to eq(b)
    end
  end

  describe ".relaton_bibdata" do
    it "exports the bibliographic record as a native Relaton item" do
      item = described_class.relaton_bibdata(model)
      expect(item).not_to be_nil
      native = JSON.parse(item.to_json)
      expect(native["schema_version"]).to be_a(String)
      docids = native["docidentifier"].map { |d| d["content"] }
      expect(docids).to include("ISO 17301-1:2016")
    end
  end

  describe ".relaton_bibliography" do
    it "exports every bibitem as a native Relaton item with a pubid" do
      entries = described_class.relaton_bibliography(model)
      expect(entries.size).to eq(23)
      expect(entries).to all(have_attributes(key: a_string_starting_with(/\A/)))
      iso712 = entries.find { |e| e.citeas.to_s.start_with?("ISO 712") }
      expect(iso712.item).to be_a(::Relaton::Bib::ItemData)
      expect(iso712.pubid).to be_a(Pubid::Iso::Identifier)
      native = JSON.parse(iso712.item.to_json)
      docids = native["docidentifier"].map { |d| d["content"] }
      expect(docids.compact.join(" ")).to include("ISO 712")
    end
  end

  describe ".plurimath_formula" do
    it "parses formula blocks into native Plurimath formulas" do
      annex = Array(model.annex).first
      formula = nil
      stack = [annex]
      until formula || stack.empty?
        node = stack.pop
        next unless node.class.respond_to?(:attributes)
        if node.class.attributes.key?(:formulas)
          formula = Array(node.formulas).first
        end
        if node.class.attributes.key?(:clause)
          stack.concat(Array(node.clause))
        end
      end
      expect(formula).not_to be_nil
      math = described_class.plurimath_formula(formula)
      expect(math).to be_a(Plurimath::Math::Formula)
      expect(math.to_latex).to be_a(String)
      expect(math.to_omml).to include("<m:oMath")
    end
  end

  describe ".pubid_identifiers" do
    it "parses document identifiers with the native pubid monogem" do
      entries = described_class.pubid_identifiers(model)
      iso = entries.find { |e| e[:original] == "ISO 17301-1:2016" }
      expect(iso[:pubid]).to be_a(Pubid::Iso::Identifier)
      expect(iso[:pubid].to_s).to eq("ISO 17301-1:2016")
      native = JSON.parse(iso[:pubid].to_json)
      expect(native["number"]).to eq("17301")
    end
  end
end
