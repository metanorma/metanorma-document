# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"

# The walk's language resolution (#53 item 3), consumer-side of
# metanorma-standoc#1243: with no element-level xml:lang emitted or
# mapped, a section resolves from its own prose (the Mko::Language
# stopword langid), then the enclosing scope, then the declared
# document language, then the explicit fallback — and every unit
# carries the provenance as lang_source.
RSpec.describe Metanorma::Mko::Project do
  let(:fixture_xml) do
    File.read(
      File.expand_path("../../fixtures/iso/is/document-en-fr-annex.xml",
                       __dir__), encoding: "utf-8"
    )
  end
  let(:model) { Metanorma::Iso::Document::Root.from_xml(fixture_xml) }
  let(:result) { described_class.call(model) }
  let(:units_by_id) { result.units.to_h { |u| [u.id, u] } }
  let(:tmpdir) { Dir.mktmpdir("mko-lang-spec") }

  after { FileUtils.rm_rf(tmpdir) }

  it "tags the English body from its own prose" do
    unit = units_by_id["u:_sec-scope"]
    expect(unit.lang).to eq("en")
    expect(unit.lang_source).to eq("heuristic")
  end

  it "tags a translated annex from its own prose — the canonical " \
     "case (an EN edition's French terminology annex is official " \
     "content to be tagged, not excluded)" do
    unit = units_by_id["u:annex-a"]
    expect(unit.lang).to eq("fr")
    expect(unit.lang_source).to eq("heuristic")
  end

  it "scopes the annex's terms section and term entries to the " \
     "annex's resolution" do
    ids = %w[u:_annex-terms u:term-instrument-de-pesage u:term-charge]
    expect(ids.map { |id| units_by_id[id].lang }).to eq(%w[fr fr fr])
    expect(ids.map { |id| units_by_id[id].lang_source })
      .to all(eq("heuristic"))
  end

  it "falls to the declared document language when a section's " \
     "prose is inconclusive" do
    unit = units_by_id["u:_sec-reserved"]
    expect(unit.lang).to eq("en")
    expect(unit.lang_source).to eq("default")
  end

  it "keeps every unit's provenance discoverable" do
    result.units.each do |u|
      expect(u.lang_source).to match(/\A(markup|heuristic|default|fallback)\z/)
    end
  end

  it "carries lang and lang_source on the wire" do
    bundle = Metanorma::Mko.export(model, to: tmpdir)
    units = File.readlines(File.join(bundle, "units.jsonl"))
      .map { |l| JSON.parse(l) }
    annex = units.find { |u| u["id"] == "u:annex-a" }
    expect(annex["lang"]).to eq("fr")
    expect(annex["lang_source"]).to eq("heuristic")
  end

  describe "element-level xml:lang (the standoc#1243 forward path)" do
    # The models carry :lang the day they map xml:lang; ModelAccess
    # reads absent attributes as nil. Subclasses simulate the landed
    # upstream — the shared model classes stay untouched.
    let(:marked_model) do
      iso = Metanorma::Iso::Document
      clause_class = Class.new(iso::Sections::IsoClauseSection) do
        attribute :lang, :string
      end
      annex_class = Class.new(iso::Sections::IsoAnnexSection) do
        attribute :lang, :string
      end
      root_class = Class.new(iso::Root) { attribute :lang, :string }
      nested = clause_class.new(id: "_nested", lang: "de")
      annex = annex_class.new(id: "_annex-m", anchor: "annex-m",
                              lang: "fr", clause: [nested])
      body = clause_class.new(id: "_body")
      bibdata = iso::Metadata::IsoBibliographicItem.new(
        docidentifier: [iso::Metadata::DocIdentifier.new(
          type: "ISO", primary: true, id: "ISO 9999",
        )],
      )
      root_class.new(
        lang: "en", bibdata: bibdata,
        sections: iso::Sections::IsoSections.new(clause: [body]),
        annex: [annex]
      )
    end
    let(:marked_units) do
      described_class.call(marked_model).units.to_h { |u| [u.id, u] }
    end

    it "resolves the root language as markup for the whole tree" do
      unit = marked_units["u:_body"]
      expect(unit.lang).to eq("en")
      expect(unit.lang_source).to eq("markup")
    end

    it "lets the nearest ancestor-or-self override win" do
      annex = marked_units["u:annex-m"]
      nested = marked_units["u:_nested"]
      expect(annex.lang).to eq("fr")
      expect(annex.lang_source).to eq("markup")
      expect(nested.lang).to eq("de")
      expect(nested.lang_source).to eq("markup")
    end
  end
end
