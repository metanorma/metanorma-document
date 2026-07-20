# frozen_string_literal: true

require "spec_helper"
require "metanorma/document"

RSpec.describe Metanorma::Document::Components::Inline::Vocabulary do
  describe "VocabularyXmlMapping" do
    it "exposes INLINE_MAPPINGS as a hash" do
      mapping = described_class::VocabularyXmlMapping::INLINE_MAPPINGS
      expect(mapping).to be_a(Hash)
      expect(mapping["em"]).to eq(:em)
      expect(mapping["fmt-stem"]).to eq(:fmt_stem)
    end

    it "includes mappings for every vocabulary attribute" do
      mapping_keys = described_class::VocabularyXmlMapping::INLINE_MAPPINGS.keys.to_set
      expect(mapping_keys).to include("em", "strong", "sub", "sup", "tt",
                                      "underline", "strike", "smallcap",
                                      "br", "tab", "xref", "eref", "link",
                                      "span", "stem", "concept", "fn",
                                      "bcp14", "fmt-stem", "fmt-concept")
    end

    it "is frozen (immutable)" do
      expect(described_class::VocabularyXmlMapping::INLINE_MAPPINGS).to be_frozen
    end
  end

  describe "included into a parent class" do
    let(:test_class) do
      # Real SpanElement includes Vocabulary; use it for the test
      Metanorma::Document::Components::Inline::SpanElement
    end

    it "declares every vocabulary attribute as a collection" do
      attrs = test_class.attributes
      %i[em strong sub sup tt stem concept fn link xref eref span
         fmt_stem fmt_concept bcp14 smallcap strike underline].each do |attr|
        expect(attrs.key?(attr)).to be(true),
                                    "#{attr} should be declared by Vocabulary"
      end
    end
  end
end
