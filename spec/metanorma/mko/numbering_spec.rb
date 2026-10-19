# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"

# The numbering composition (metanorma-document#93): the 0.4.x
# presentation renders BARE autonum fragments for iso-tree terms
# sections — the body fmt-title says "7" where the clause tree says
# "3.1.7", and the preface's TOC carries the same bare fragment. The
# TOC (processed after the body sections) used to shadow the composed
# numbers: terms-section units cited "7", their terms cited it too,
# and the section itself fell back to its parent's anchor. The registry
# now harvests every fragment FIRST and the tree pass composes after,
# so a bare fragment composes under its registered parent while a
# composed autonum and a top-level bare number stand.
RSpec.describe Metanorma::Mko do
  class << self
    def fixture_model(xml, key)
      instance_variable_get(:"@#{key}") ||
        instance_variable_set(:"@#{key}", Metanorma::Iso::Document::Root.from_xml(xml))
    end
  end

  let(:semantic_xml) do
    File.read(fixture_path("iso/is/document-nested-terms.xml"), encoding: "utf-8")
  end

  let(:presentation_xml) do
    File.read(fixture_path("iso/is/document-nested-terms.presentation.xml"),
              encoding: "utf-8")
  end

  let(:tmpdir) { Dir.mktmpdir("mko-numbering") }

  after { FileUtils.rm_rf(tmpdir) }

  def fixture_path(rel)
    File.expand_path("../../fixtures/#{rel}", __dir__)
  end

  def units
    bundle = described_class.export(
      self.class.fixture_model(semantic_xml, :sem),
      to: tmpdir,
      presentation_xml: self.class.fixture_model(presentation_xml, :pres),
    )
    File.readlines(File.join(bundle, "units.jsonl")).map { |l| JSON.parse(l) }
  end

  it "composes the nested terms-section's number from its parent chain" do
    tsec = units.find { |u| u["title"] == "Measurement and error terms" }
    expect(tsec["number"]).to eq("3.1.7")
    expect(tsec["cite_as"]).to eq("3.1")
  end

  it "cites each term at its clause — the bare TOC fragment does not shadow" do
    term = units.find { |u| u["type"] == "term" }
    expect(term["cite_as"]).to eq("3.1.7")
    expect(term["number"]).to eq("1")
  end

  it "composes the enclosing clause from its own bare fragment" do
    outer = units.find { |u| u["title"] == "Terminology" }
    expect(outer["number"]).to eq("3.1")
  end

  it "leaves top-level bare numbers and composed autonums alone" do
    top = units.find { |u| u["title"] == "Measurement" }
    expect(top["number"]).to eq("3")
  end
end
