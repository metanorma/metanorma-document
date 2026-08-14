# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/iso_renderer"

RSpec.describe "Config-driven flavor metadata" do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::Iso::Document::Root.from_xml(xml) }
  let(:renderer) do
    r = Metanorma::Html::IsoRenderer.new
    r.document = doc
    r
  end

  describe "theme auto-resolution" do
    it "resolves ISO theme from IsoDocument" do
      expect(renderer.theme).not_to be_nil
      expect(renderer.theme.primary).to eq("#b3000c")
    end

    it "resolves publisher metadata from theme config" do
      expect(renderer.theme.publishers).to include("ISO")
    end

    it "resolves publisher_name from theme config" do
      expect(renderer.theme.publisher_name).to eq("ISO")
    end

    it "resolves logo map from theme config" do
      expect(renderer.theme.logos).to be_a(Hash)
      expect(renderer.theme.logos["ISO"]).to eq("iso-logo.svg")
    end
  end

  describe "flavor_publishers" do
    it "returns publishers from theme config" do
      expect(renderer.flavor_publishers(nil)).to include("ISO")
    end
  end

  describe "flavor_publisher_name" do
    it "returns publisher_name from theme config" do
      expect(renderer.flavor_publisher_name).to eq("ISO")
    end
  end

  describe "publisher_logo_map" do
    it "returns logos from theme config" do
      expect(renderer.publisher_logo_map).to be_a(Hash)
    end
  end

  describe "flavor resolution from document class" do
    it "identifies IsoDocument namespace" do
      expect(renderer.flavor_name).to eq(:iso)
    end
  end
end
