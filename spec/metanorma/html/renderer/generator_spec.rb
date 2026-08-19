# frozen_string_literal: true

require "spec_helper"
require "metanorma/ogc/document"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::Generator do
  describe ".renderer_for" do
    it "returns BaseRenderer for Document::Root" do
      doc = Metanorma::Document::Root.new
      expect(described_class.renderer_for(doc)).to eq(Metanorma::Html::BaseRenderer)
    end

    it "returns IsoRenderer for IsoDocument::Root" do
      doc = Metanorma::Iso::Document::Root.new
      expect(described_class.renderer_for(doc)).to eq(SpecFlavors::IsoRenderer)
    end

    it "returns StandardRenderer for StandardDocument::Root" do
      doc = Metanorma::Standoc::Document::Root.new
      expect(described_class.renderer_for(doc)).to eq(Metanorma::Html::StandardRenderer)
    end

    it "returns OgcRenderer for OgcDocument::Root" do
      doc = Metanorma::Ogc::Document::Root.new
      expect(described_class.renderer_for(doc)).to eq(SpecFlavors::OgcRenderer)
    end
  end
end
