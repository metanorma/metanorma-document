# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe "Architecture improvements" do
  let(:xml_path) { File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml", __dir__) }
  let(:xml) { File.read(xml_path) }
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
  let(:html) { Metanorma::Html::Generator.generate(doc) }
  let(:page) { Nokogiri::HTML(html) }

  describe "respond_to? elimination" do
    it "extract_doctype uses is_a? for IsoBibliographicItem" do
      renderer = Metanorma::Html::IsoRenderer.new
      bibdata = doc.bibdata
      doctype = renderer.send(:extract_doctype, bibdata)
      doctype.should be_a(String)
    end

    it "extract_doctype returns nil for non-ISO bibdata" do
      renderer = Metanorma::Html::IsoRenderer.new
      doctype = renderer.send(:extract_doctype, "not a bibdata")
      doctype.should be_nil
    end
  end

  describe "RendererContext delegation" do
    let(:renderer) { Metanorma::Html::IsoRenderer.new }
    let(:ctx) { renderer.renderer_context }

    it "delegates safe_attr via method_missing" do
      obj = Struct.new(:id).new("test-id")
      ctx.safe_attr(obj, :id).should eq("test-id")
    end

    it "delegates escape_html via method_missing" do
      ctx.escape_html("<b>").should eq("&lt;b&gt;")
    end

    it "delegates methods with keyword arguments" do
      renderer.instance_variable_set(:@figure_entries, [])
      ctx.register_figure_entry(id: "fig-1", text: "Figure 1")
      entries = renderer.instance_variable_get(:@figure_entries)
      entries.length.should eq(1)
      entries.first[:id].should eq("fig-1")
    end

    it "responds_to? returns true for delegated methods" do
      ctx.respond_to?(:safe_attr).should be true
      ctx.respond_to?(:render_paragraph).should be true
    end

    it "responds_to? returns false for unknown methods" do
      ctx.respond_to?(:nonexistent_method_xyz).should be false
    end

    it "raises NoMethodError for unknown methods" do
      -> { ctx.nonexistent_method_xyz }.should raise_error(NoMethodError)
    end
  end

  describe "BLOCK_TYPES optimization" do
    it "is a frozen Hash" do
      types = Metanorma::Html::BaseRenderer::BLOCK_TYPES
      types.should be_frozen
      types.should be_a(Hash)
    end

    it "provides O(1) exact match for block types" do
      types = Metanorma::Html::BaseRenderer::BLOCK_TYPES
      types.should have_key(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
      types[Metanorma::Document::Components::Paragraphs::ParagraphBlock].should be true
    end

    it "block_element? returns true for registered types" do
      renderer = Metanorma::Html::BaseRenderer.new
      para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new(text: "test")
      renderer.send(:block_element?, para).should be true
    end

    it "block_element? returns false for non-block types" do
      renderer = Metanorma::Html::BaseRenderer.new
      renderer.send(:block_element?, "string").should be false
    end
  end

  describe "ToC Liquid template" do
    it "renders ToC with toc-level classes" do
      toc_links = page.css(".toc-link")
      toc_links.length.should be > 0
    end

    it "renders figure list in ToC when figures exist" do
      fig_header = page.at_css('[data-list="figures"]')
      fig_header.should_not be_nil
      fig_header.text.should include("Figures")
    end

    it "renders table list in ToC when tables exist" do
      tbl_header = page.at_css('[data-list="tables"]')
      tbl_header.should_not be_nil
      tbl_header.text.should include("Tables")
    end

    it "renders toc-divider when special lists exist" do
      page.at_css(".toc-divider").should_not be_nil
    end
  end

  describe "inline collections registry dispatch" do
    it "renders MathElement in text collections via registry" do
      # Math elements in inline text should be rendered by render_math
      # (previously they were special-cased with inline if/elsif)
      renderer = Metanorma::Html::BaseRenderer.new
      renderer.send(:lookup_dispatch,
                     Metanorma::Document::Components::Inline::MathElement,
                     :inline_registry).should eq(:render_math)
    end

    it "renders AsciimathElement in text collections via registry" do
      renderer = Metanorma::Html::BaseRenderer.new
      renderer.send(:lookup_dispatch,
                     Metanorma::Document::Components::Inline::AsciimathElement,
                     :inline_registry).should eq(:render_asciimath)
    end
  end

  describe "render_ordered_inline no silent error rescue" do
    it "does not have a rescue StandardError block" do
      source = File.read(File.expand_path("../../../../lib/metanorma/html/base_renderer.rb", __dir__))
      method_source = source[/def render_ordered_inline.*?(?=      def |\z)/m]
      method_source.should_not include("rescue StandardError")
    end
  end
end
