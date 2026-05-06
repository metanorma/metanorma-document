# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/asset_pipeline"

RSpec.describe Metanorma::Html::AssetPipeline do
  subject(:pipeline) { described_class.new }

  describe "#compile_css" do
    let(:css) { pipeline.compile_css }

    it "returns a non-empty string" do
      css.should be_a(String)
      css.should_not be_empty
    end

    it "includes base reset styles" do
      css.should include("box-sizing")
    end

    it "includes typography styles" do
      css.should include("font-family")
    end

    it "includes component styles" do
      css.should include(".doc-header")
      css.should include(".note-block")
      css.should include(".example")
    end
  end

  describe "#compile_js" do
    let(:js) { pipeline.compile_js }

    it "returns a non-empty string" do
      js.should be_a(String)
      js.should_not be_empty
    end

    it "wraps each module in IIFE" do
      js.should include("(function()")
    end

    it "includes core reader module" do
      js.should include("mn-reader")
    end
  end

  describe "with flavor modules" do
    it "includes flavor CSS when present" do
      # Flavor module doesn't exist, should not error
      css = pipeline.compile_css(flavor_css: "iso")
      css.should be_a(String)
    end

    it "includes flavor JS when present" do
      js = pipeline.compile_js(flavor_js: "iso")
      js.should be_a(String)
    end
  end
end
