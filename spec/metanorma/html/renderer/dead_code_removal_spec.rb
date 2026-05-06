# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Dead code removal" do
  it "does not load ComponentRegistry" do
    Metanorma::Html.constants.should_not include(:ComponentRegistry)
  end

  it "does not define registers_doc_type on IsoRenderer" do
    Metanorma::Html::IsoRenderer.should_not respond_to(:registers_doc_type)
  end

  it "does not define doc_types on IsoRenderer" do
    Metanorma::Html::IsoRenderer.should_not respond_to(:doc_types)
  end

  it "does not define build_reader_controls on BaseRenderer" do
    Metanorma::Html::BaseRenderer.new.should_not respond_to(:build_reader_controls)
  end

  it "does not define detect_publishers on BaseRenderer" do
    Metanorma::Html::BaseRenderer.new.should_not respond_to(:detect_publishers)
  end

  it "component_registry.rb file does not exist" do
    path = File.expand_path("../../../lib/metanorma/html/component_registry.rb", __dir__)
    File.exist?(path).should be(false)
  end
end
