# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe "Architecture improvements" do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::Iso::Document::Root.from_xml(xml) }
  let(:html) { Metanorma::Html::Generator.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  describe "respond_to? elimination" do
    it "extract_doctype uses is_a? for IsoBibliographicItem" do
      renderer = Metanorma::Html::IsoRenderer.new
      bibdata = doc.bibdata
      doctype = renderer.extract_doctype(bibdata)
      expect(doctype).to be_a(String)
    end

    it "extract_doctype returns nil for non-ISO bibdata" do
      renderer = Metanorma::Html::IsoRenderer.new
      doctype = renderer.extract_doctype("not a bibdata")
      expect(doctype).to be_nil
    end
  end

  describe "RendererContext delegation" do
    let(:renderer) { Metanorma::Html::IsoRenderer.new }
    let(:ctx) { renderer.renderer_context }

    it "delegates safe_attr via explicit method" do
      obj = Struct.new(:id).new("test-id")
      expect(ctx.safe_attr(obj, :id)).to eq("test-id")
    end

    it "delegates escape_html via explicit method" do
      expect(ctx.escape_html("<b>")).to eq("&lt;b&gt;")
    end

    it "delegates methods with keyword arguments" do
      renderer.figure_entries.clear
      ctx.register_figure_entry(id: "fig-1", text: "Figure 1")
      entries = renderer.figure_entries
      expect(entries.length).to eq(1)
      expect(entries.first[:id]).to eq("fig-1")
    end

    it "responds_to? returns true for delegated methods" do
      expect(ctx.respond_to?(:safe_attr)).to be true
      expect(ctx.respond_to?(:render_paragraph)).to be true
    end

    it "responds_to? returns false for unknown methods" do
      expect(ctx.respond_to?(:nonexistent_method_xyz)).to be false
    end

    it "raises NoMethodError for unknown methods" do
      expect { ctx.nonexistent_method_xyz }.to raise_error(NoMethodError)
    end
  end

  describe "BLOCK_TYPES optimization" do
    it "is a frozen Hash" do
      types = Metanorma::Html::BaseRenderer::BLOCK_TYPES
      expect(types).to be_frozen
      expect(types).to be_a(Hash)
    end

    it "provides O(1) exact match for block types" do
      types = Metanorma::Html::BaseRenderer::BLOCK_TYPES
      expect(types).to have_key(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
      expect(types[Metanorma::Document::Components::Paragraphs::ParagraphBlock]).to be true
    end

    it "block_element? returns true for registered types" do
      renderer = Metanorma::Html::BaseRenderer.new
      para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new(text: "test")
      expect(renderer.block_element?(para)).to be true
    end

    it "block_element? returns false for non-block types" do
      renderer = Metanorma::Html::BaseRenderer.new
      expect(renderer.block_element?("string")).to be false
    end
  end

  describe "ToC Liquid template" do
    it "renders ToC with toc-level classes" do
      toc_links = page.css(".toc-link")
      expect(toc_links.length).to be > 0
    end

    it "renders figure list in ToC when figures exist" do
      fig_header = page.at_css('[data-list="figures"]')
      expect(fig_header).not_to be_nil
      expect(fig_header.text).to include("Figures")
    end

    it "renders table list in ToC when tables exist" do
      tbl_header = page.at_css('[data-list="tables"]')
      expect(tbl_header).not_to be_nil
      expect(tbl_header.text).to include("Tables")
    end

    it "renders toc-divider when special lists exist" do
      expect(page.at_css(".toc-divider")).not_to be_nil
    end
  end

  describe "inline collections registry dispatch" do
    it "renders MathElement in text collections via registry" do
      renderer = Metanorma::Html::BaseRenderer.new
      expect(renderer.lookup_dispatch(
               Metanorma::Document::Components::Inline::MathElement,
               :inline_registry,
             )).to eq(:render_math)
    end

    it "renders AsciimathElement in text collections via registry" do
      renderer = Metanorma::Html::BaseRenderer.new
      expect(renderer.lookup_dispatch(
               Metanorma::Document::Components::Inline::AsciimathElement,
               :inline_registry,
             )).to eq(:render_asciimath)
    end
  end

  describe "render_ordered_inline no silent error rescue" do
    it "does not have a rescue StandardError block" do
      source = File.read(File.expand_path(
                           "../../../../lib/metanorma/html/renderers/inline_renderer.rb", __dir__
                         ))
      method_source = source[/def render_ordered_inline.*?(?=    def |\z)/m]
      expect(method_source).not_to include("rescue StandardError")
    end
  end
end
