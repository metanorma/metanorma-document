# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/iso_renderer"

RSpec.describe "Pubid rendering" do
  let(:renderer) { Metanorma::Html::IsoRenderer.new }

  describe "#parse_pubid" do
    it "returns nil for nil input" do
      expect(renderer.parse_pubid(nil)).to be_nil
    end

    it "returns nil for empty string" do
      expect(renderer.parse_pubid("")).to be_nil
      expect(renderer.parse_pubid("  ")).to be_nil
    end
  end

  describe "#pubid_to_html" do
    it "returns nil for nil identifier" do
      expect(renderer.pubid_to_html(nil)).to be_nil
    end
  end
end
