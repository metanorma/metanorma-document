# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::Generator do
  describe ".renderer_for" do
    it "returns BaseRenderer for Document::Root" do
      doc = Metanorma::Document::Root.new
      described_class.renderer_for(doc).should eq(Metanorma::Html::BaseRenderer)
    end

    it "returns IsoRenderer for IsoDocument::Root" do
      doc = Metanorma::IsoDocument::Root.new
      described_class.renderer_for(doc).should eq(Metanorma::Html::IsoRenderer)
    end

    it "returns StandardRenderer for StandardDocument::Root" do
      doc = Metanorma::StandardDocument::Root.new
      described_class.renderer_for(doc).should eq(Metanorma::Html::StandardRenderer)
    end

    it "returns OgcRenderer for OgcDocument::Root" do
      doc = Metanorma::OgcDocument::Root.new
      described_class.renderer_for(doc).should eq(Metanorma::Html::OgcRenderer)
    end
  end
end
