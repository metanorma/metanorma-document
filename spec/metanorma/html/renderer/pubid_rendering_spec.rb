# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/iso_renderer"

RSpec.describe "Pubid rendering" do
  let(:renderer) { Metanorma::Html::IsoRenderer.new }

  describe "#parse_pubid" do
    it "returns nil for nil input" do
      renderer.parse_pubid(nil).should be_nil
    end

    it "returns nil for empty string" do
      renderer.parse_pubid("").should be_nil
      renderer.parse_pubid("  ").should be_nil
    end
  end

  describe "#pubid_to_html" do
    it "returns nil for nil identifier" do
      renderer.pubid_to_html(nil).should be_nil
    end
  end
end
