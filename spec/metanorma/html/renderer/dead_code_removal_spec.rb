# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Dead code removal" do
  it "does not load ComponentRegistry" do
    expect(Metanorma::Html.constants).not_to include(:ComponentRegistry)
  end

  it "does not define registers_doc_type on IsoRenderer" do
    expect(Metanorma::Html::IsoRenderer).not_to respond_to(:registers_doc_type)
  end

  it "does not define doc_types on IsoRenderer" do
    expect(Metanorma::Html::IsoRenderer).not_to respond_to(:doc_types)
  end

  it "does not define build_reader_controls on BaseRenderer" do
    expect(Metanorma::Html::BaseRenderer.new).not_to respond_to(:build_reader_controls)
  end

  it "does not define detect_publishers on BaseRenderer" do
    expect(Metanorma::Html::BaseRenderer.new).not_to respond_to(:detect_publishers)
  end

  it "component_registry.rb file does not exist" do
    path = File.expand_path(
      "../../../lib/metanorma/html/component_registry.rb", __dir__
    )
    expect(File.exist?(path)).to be(false)
  end
end
