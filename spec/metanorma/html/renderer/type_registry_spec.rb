# frozen_string_literal: true

require "spec_helper"
require "metanorma/iec/document"
require "metanorma/html/generator"

RSpec.describe "OCP type registry" do
  describe "BaseRenderer registry" do
    it "has render_registry as a class method" do
      expect(Metanorma::Html::BaseRenderer).to respond_to(:render_registry)
    end

    it "has inline_registry as a class method" do
      expect(Metanorma::Html::BaseRenderer).to respond_to(:inline_registry)
    end

    it "registers ParagraphBlock in render_registry" do
      registry = Metanorma::Html::BaseRenderer.render_registry
      expect(registry).to have_key(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
    end

    it "registers EmRawElement in inline_registry" do
      registry = Metanorma::Html::BaseRenderer.inline_registry
      expect(registry).to have_key(Metanorma::Document::Components::Inline::EmRawElement)
    end
  end

  describe "StandardRenderer registry" do
    it "registers StandardDocument::Root" do
      registry = Metanorma::Html::StandardRenderer.render_registry
      expect(registry).to have_key(Metanorma::Standoc::Document::Root)
      expect(registry[Metanorma::Standoc::Document::Root]).to eq(:render_standard_document)
    end

    it "does not leak into BaseRenderer registry" do
      base = Metanorma::Html::BaseRenderer.render_registry
      expect(base).not_to have_key(Metanorma::Standoc::Document::Root)
    end
  end

  describe "IsoRenderer registry" do
    it "registers IsoDocument::Root" do
      registry = Metanorma::Html::IsoRenderer.render_registry
      expect(registry).to have_key(Metanorma::Iso::Document::Root)
      expect(registry[Metanorma::Iso::Document::Root]).to eq(:render_document)
    end

    it "registers TermOrigin in inline_registry" do
      registry = Metanorma::Html::IsoRenderer.inline_registry
      expect(registry).to have_key(Metanorma::Iso::Document::Terms::TermOrigin)
    end

    it "does not leak into BaseRenderer or StandardRenderer registries" do
      base = Metanorma::Html::BaseRenderer.render_registry
      standard = Metanorma::Html::StandardRenderer.render_registry
      expect(base).not_to have_key(Metanorma::Iso::Document::Root)
      expect(standard).not_to have_key(Metanorma::Iso::Document::Root)
    end
  end

  describe "ancestor chain lookup" do
    let(:xml_path) do
      File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                       __dir__)
    end
    let(:xml) { File.read(xml_path) }
    let(:doc) { Metanorma::Iso::Document::Root.from_xml(xml) }
    let(:html) { Metanorma::Html::Generator.generate(doc) }
    let(:page) { Nokogiri::HTML(html) }

    it "finds IsoRenderer types via registry dispatch" do
      # ISO document renders via IsoRenderer's registry
      expect(page.at_css("main")).not_to be_nil
      expect(page.css("main *").length).to be > 0
    end

    it "falls through to BaseRenderer for paragraph blocks" do
      # Paragraphs are in BaseRenderer registry, found via ancestor traversal
      expect(page.at_css("main p")).not_to be_nil
    end

    it "falls through to BaseRenderer for table blocks" do
      expect(page.at_css("main table")).not_to be_nil
    end
  end

  describe "flavor independence" do
    it "each flavor renderer has its own registry object" do
      iso_reg = Metanorma::Html::IsoRenderer.render_registry
      iec_reg = Metanorma::Html::IecRenderer.render_registry
      expect(iso_reg).not_to equal(iec_reg)
    end

    it "flavor registry contains only its own types, not parent types" do
      # IecRenderer registers IecDocument::Root but not IsoDocument::Root
      iec_reg = Metanorma::Html::IecRenderer.render_registry
      expect(iec_reg).to have_key(Metanorma::Iec::Document::Root)
      expect(iec_reg).not_to have_key(Metanorma::Iso::Document::Root)
    end

    it "flavor renderer can register its own types independently" do
      # Simulate a new flavor registering a type
      flavor_class = Class.new(Metanorma::Html::IsoRenderer) do
        register_render String, :render_noop
      end
      expect(flavor_class.render_registry).to have_key(String)
      expect(Metanorma::Html::IsoRenderer.render_registry).not_to have_key(String)
    end
  end
end
