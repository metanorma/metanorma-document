# frozen_string_literal: true

require "spec_helper"
require "metanorma/document/grammar_vocabulary"

# metanorma-document#2 — the element-coverage enumeration, as a gate.
# The vocabulary and its classification live in
# Metanorma::Document::GrammarVocabulary (lib); this spec asserts its
# invariants. Refresh with `rake grammar_coverage` against a
# standoc-models checkout when the grammars change.
V = Metanorma::Document::GrammarVocabulary

RSpec.describe "standoc grammar element coverage" do
  def mapped_element_names
    Dir[File.expand_path("../../../lib/**/*.rb", __dir__)].flat_map do |f|
      File.read(f, encoding: "utf-8")
        .scan(/(?:map_element|element)\s+"([a-zA-Z0-9_.:-]+)"/)
        .flatten
    end.uniq
  end
  it "accounts for every grammar element exactly once" do
    mapped = mapped_element_names
    accounted = mapped + V::DELEGATED.values.flatten + V::KNOWN_GAPS

    overlaps = accounted.tally.select { |_, n| n > 1 }.keys
    expect(overlaps).to be_empty,
                        "elements accounted for more than once: #{overlaps.join(', ')}"

    missing = (V::SEMANTIC_ELEMENTS + V::PRESENTATION_ELEMENTS) - accounted
    expect(missing).to be_empty,
                       "grammar elements with no mapping and no classification: " \
                       "#{missing.join(', ')}"
  end

  it "classifies delegated and gap elements that exist in the grammar" do
    listed = V::DELEGATED.values.flatten + V::KNOWN_GAPS
    unknown = listed - (V::SEMANTIC_ELEMENTS + V::PRESENTATION_ELEMENTS)
    expect(unknown).to be_empty,
                       "classification lists name elements the grammar does " \
                       "not define (stale?): #{unknown.join(', ')}"
  end

  it "maps the vocabulary added for #2 and #63" do
    mapped = mapped_element_names
    %w[ruby ruby-pronunciation ruby-annotation rb columnbreak svgmap
       imagemap area coords radius target fmt-eref fmt-origin
       fmt-source fmt-figure fmt-ul fmt-ol fmt-date-inline
       sourcelocalityStack].each do |el|
      expect(mapped).to include(el), "#{el} must stay mapped in this gem"
    end
  end
end
