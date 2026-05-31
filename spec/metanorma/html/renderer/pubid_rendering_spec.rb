# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/iso_renderer"

RSpec.describe Metanorma::Html::Renderers::PubidRenderer do
  let(:coordinator) do
    renderer = Metanorma::Html::IsoRenderer.new
    renderer.instance_variable_set(:@document, Metanorma::IsoDocument::Root.new)
    renderer
  end
  let(:pubid_renderer) { coordinator.pubid_renderer }

  describe "#parse_pubid" do
    it "returns nil for nil input" do
      pubid_renderer.parse_pubid(nil).should be_nil
    end

    it "returns nil for empty string" do
      pubid_renderer.parse_pubid("").should be_nil
      pubid_renderer.parse_pubid("  ").should be_nil
    end
  end

  describe "#pubid_to_html" do
    it "returns nil for nil identifier" do
      pubid_renderer.pubid_to_html(nil).should be_nil
    end
  end
end
