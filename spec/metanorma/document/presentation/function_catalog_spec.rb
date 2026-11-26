# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "presentation function catalog" do
  let(:catalog) do
    YAML.load_file(File.expand_path("../../../../docs/presentation-engine/function-catalog.yml", __dir__))
  end

  it "classifies all 29 isodoc presentation_function files" do
    expect(catalog["files"].size).to eq(29)
    expect(catalog["files"].map { |f| f["file"] }.uniq.size).to eq(29)
    expect(catalog["files"].map { |f| f["kind"] }.uniq - %w[declarative algorithmic mixed]).to be_empty
  end

  it "records a rationale and methods for each file" do
    catalog["files"].each do |f|
      expect(f["rationale"].to_s).not_to be_empty, f["file"]
      expect(f["methods"]).not_to be_empty, f["file"]
    end
  end

  it "lists flavor deltas as a per-flavor hash" do
    catalog["files"].each { |f| expect(f["flavor_overrides"]).to be_a(Hash) }
    expect(catalog["files"].sum { |f| f["flavor_overrides"].size }).to be > 0
  end

  it "follows the 1.20 flavor scope: vsd dropped, csd unconfirmed, oiml/nist/bsi kept" do
    scanned = catalog["source"]["flavors_scanned"]
    status = catalog["source"]["flavor_status"]
    expect(scanned).not_to include("vsd")
    expect(scanned).to include("oiml", "nist", "bsi")
    expect(status["unconfirmed_skip"]).to eq(["csd"])
    expect(scanned).to include("mpfa", "csa")
    expect(status["assigned_umbrella"].keys).to eq(%w[mpfa csa])
    expect(status["private_active"]).to eq(%w[nist bsi])
    expect(catalog["files"].flat_map { |f| f["flavor_overrides"].keys }).not_to include("vsd")
  end
end
