# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"

RSpec.describe Metanorma::Mko::Diff do
  let(:source_xml) do
    File.read(File.expand_path("../../fixtures/standoc/requirements/document.xml",
                               __dir__), encoding: "utf-8")
  end
  let(:dir) { Dir.mktmpdir("mko-diff") }

  def fixture_path(rel)
    File.expand_path("../../fixtures/#{rel}", __dir__)
  end

  after { FileUtils.remove_entry(dir) }

  it "emits a structured change set between editions" do
    # edition B: one restated requirement, one new clause, the annex
    # term removed, a table value edited
    edition_b = source_xml
      .sub("Sensor readings shall be accurate to within ±0.1 % of the reference value.",
           "Sensor readings shall be accurate to within ±0.05 % of the reference value.")
      .sub("</sections>",
           "<clause id=\"_sec-new\" anchor=\"new-clause\"><title>Marking</title>" \
           "<p id=\"_p-mark\">Sensors shall bear a marking.</p></clause></sections>")
      .sub(%r{<annex id="_annex-terms".*?</annex>}m, "")

    a = Metanorma::Mko.export(source_xml, to: File.join(dir, "a")).path
    b = Metanorma::Mko.export(edition_b, to: File.join(dir, "b")).path

    diff = described_class.between(a, b)
    expect(diff["from"]).to eq("SNR-1")
    expect(diff["to"]).to eq("SNR-1")

    added = diff["added"].map { |u| u["anchor"] }
    expect(added).to include("new-clause")

    # NB: the standoc tree's Term does not declare :anchor (the iso
    # tree does) — anchorless elements key by id; upstream model gap.
    removed = diff["removed"].map { |u| u["anchor"] }
    expect(removed).to include("_term-annex-load-cell", "_annex-terms")

    changed = diff["changed"]
    restated = changed.find { |u| u["anchor"] == "req-sensor-accuracy" }
    expect(restated["fields"]).to include("text", "statement")

    # unchanged units do not appear
    expect(changed.map { |u| u["anchor"] }).not_to include("req-battery")

    path = described_class.export(a, b, to: dir)
    expect(File.basename(path)).to eq("snr-1-to-snr-1.diff.json")
    on_disk = JSON.parse(File.read(path))
    expect(on_disk["changed"].size).to eq(diff["changed"].size)
  end
end
