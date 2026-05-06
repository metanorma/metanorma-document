# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::BaseRenderer::RendererContext do
  let(:renderer) { Metanorma::Html::BaseRenderer.new }
  let(:ctx) { renderer.renderer_context }

  it "exposes safe_attr" do
    obj = Struct.new(:id).new("test-id")
    ctx.safe_attr(obj, :id).should eq("test-id")
  end

  it "exposes escape_html" do
    ctx.escape_html("<b>").should eq("&lt;b&gt;")
  end

  it "exposes capture_output" do
    result = ctx.capture_output { renderer.instance_variable_get(:@output) << "hello" }
    result.should eq("hello")
  end

  it "exposes render_liquid" do
    result = ctx.render_liquid("_doc_title.html.liquid", { "title" => "Test" })
    result.should include("Test")
    result.should include("doc-title")
  end

  it "returns nil for missing attributes via safe_attr" do
    obj = Struct.new(:id).new("test")
    ctx.safe_attr(obj, :nonexistent).should be_nil
  end
end
