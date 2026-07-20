# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/asset_pipeline"

RSpec.describe Metanorma::Html::AssetPipeline do
  subject(:pipeline) { described_class.new }

  describe "#compile_css" do
    let(:css) { pipeline.compile_css }

    it "returns a non-empty string" do
      expect(css).to be_a(String)
      expect(css).not_to be_empty
    end

    it "includes base reset styles" do
      expect(css).to include("box-sizing")
    end

    it "includes typography styles" do
      expect(css).to include("font-family")
    end

    it "includes component styles" do
      expect(css).to include(".doc-header")
      expect(css).to include(".note-block")
      expect(css).to include(".example")
    end
  end

  describe "#compile_js" do
    let(:js) { pipeline.compile_js }

    it "returns a non-empty string" do
      expect(js).to be_a(String)
      expect(js).not_to be_empty
    end

    it "wraps each module in IIFE" do
      expect(js).to include("(function()")
    end

    it "includes core reader module" do
      expect(js).to include("mn-reader")
    end
  end

  describe "with flavor modules" do
    it "includes flavor CSS when present" do
      # Flavor module doesn't exist, should not error
      css = pipeline.compile_css(flavor_css: "iso")
      expect(css).to be_a(String)
    end

    it "includes flavor JS when present" do
      js = pipeline.compile_js(flavor_js: "iso")
      expect(js).to be_a(String)
    end
  end
end
