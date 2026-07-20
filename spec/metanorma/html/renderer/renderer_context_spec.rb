# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::BaseRenderer::RendererContext do
  let(:renderer) { Metanorma::Html::BaseRenderer.new }
  let(:ctx) { renderer.renderer_context }

  it "exposes safe_attr" do
    obj = Struct.new(:id).new("test-id")
    expect(ctx.safe_attr(obj, :id)).to eq("test-id")
  end

  it "exposes escape_html" do
    expect(ctx.escape_html("<b>")).to eq("&lt;b&gt;")
  end

  it "delegates render_paragraph" do
    para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new
    result = ctx.render_paragraph(para)
    expect(result).to include("<p>")
  end

  it "exposes render_liquid" do
    result = ctx.render_liquid("_doc_title.html.liquid", { "title" => "Test" })
    expect(result).to include("Test")
    expect(result).to include("doc-title")
  end

  it "returns nil for missing attributes via safe_attr" do
    obj = Struct.new(:id).new("test")
    expect(ctx.safe_attr(obj, :nonexistent)).to be_nil
  end
end
