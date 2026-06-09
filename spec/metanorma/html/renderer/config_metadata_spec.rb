# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/iso_renderer"

RSpec.describe "Config-driven flavor metadata" do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
  let(:renderer) do
    r = Metanorma::Html::IsoRenderer.new
    r.document = doc
    r
  end

  describe "theme auto-resolution" do
    it "resolves ISO theme from IsoDocument" do
      renderer.theme.should_not be_nil
      renderer.theme.primary.should eq("#b3000c")
    end

    it "resolves publisher metadata from theme config" do
      renderer.theme.publishers.should include("ISO")
    end

    it "resolves publisher_name from theme config" do
      renderer.theme.publisher_name.should eq("ISO")
    end

    it "resolves logo map from theme config" do
      renderer.theme.logos.should be_a(Hash)
      renderer.theme.logos["ISO"].should eq("iso-logo.svg")
    end
  end

  describe "flavor_publishers" do
    it "returns publishers from theme config" do
      renderer.flavor_publishers(nil).should include("ISO")
    end
  end

  describe "flavor_publisher_name" do
    it "returns publisher_name from theme config" do
      renderer.flavor_publisher_name.should eq("ISO")
    end
  end

  describe "publisher_logo_map" do
    it "returns logos from theme config" do
      renderer.publisher_logo_map.should be_a(Hash)
    end
  end

  describe "flavor resolution from document class" do
    it "identifies IsoDocument namespace" do
      renderer.flavor_name.should eq(:iso)
    end
  end
end
