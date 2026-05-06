# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe "OCP type registry" do
  describe "BaseRenderer registry" do
    it "has render_registry as a class method" do
      Metanorma::Html::BaseRenderer.should respond_to(:render_registry)
    end

    it "has inline_registry as a class method" do
      Metanorma::Html::BaseRenderer.should respond_to(:inline_registry)
    end

    it "registers ParagraphBlock in render_registry" do
      registry = Metanorma::Html::BaseRenderer.render_registry
      registry.should have_key(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
    end

    it "registers EmRawElement in inline_registry" do
      registry = Metanorma::Html::BaseRenderer.inline_registry
      registry.should have_key(Metanorma::Document::Components::Inline::EmRawElement)
    end
  end

  describe "StandardRenderer registry" do
    it "registers StandardDocument::Root" do
      registry = Metanorma::Html::StandardRenderer.render_registry
      registry.should have_key(Metanorma::StandardDocument::Root)
      registry[Metanorma::StandardDocument::Root].should eq(:render_standard_document)
    end

    it "does not leak into BaseRenderer registry" do
      base = Metanorma::Html::BaseRenderer.render_registry
      base.should_not have_key(Metanorma::StandardDocument::Root)
    end
  end

  describe "IsoRenderer registry" do
    it "registers IsoDocument::Root" do
      registry = Metanorma::Html::IsoRenderer.render_registry
      registry.should have_key(Metanorma::IsoDocument::Root)
      registry[Metanorma::IsoDocument::Root].should eq(:render_document)
    end

    it "registers TermOrigin in inline_registry" do
      registry = Metanorma::Html::IsoRenderer.inline_registry
      registry.should have_key(Metanorma::IsoDocument::Terms::TermOrigin)
    end

    it "does not leak into BaseRenderer or StandardRenderer registries" do
      base = Metanorma::Html::BaseRenderer.render_registry
      standard = Metanorma::Html::StandardRenderer.render_registry
      base.should_not have_key(Metanorma::IsoDocument::Root)
      standard.should_not have_key(Metanorma::IsoDocument::Root)
    end
  end

  describe "ancestor chain lookup" do
    let(:xml_path) { File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml", __dir__) }
    let(:xml) { File.read(xml_path) }
    let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
    let(:html) { Metanorma::Html::Generator.generate(doc) }
    let(:page) { Nokogiri::HTML(html) }

    it "finds IsoRenderer types via registry dispatch" do
      # ISO document renders via IsoRenderer's registry
      page.at_css("main").should_not be_nil
      page.css("main *").length.should be > 0
    end

    it "falls through to BaseRenderer for paragraph blocks" do
      # Paragraphs are in BaseRenderer registry, found via ancestor traversal
      page.at_css("main p").should_not be_nil
    end

    it "falls through to BaseRenderer for table blocks" do
      page.at_css("main table").should_not be_nil
    end
  end

  describe "flavor independence" do
    it "each flavor renderer has its own registry object" do
      iso_reg = Metanorma::Html::IsoRenderer.render_registry
      iec_reg = Metanorma::Html::IecRenderer.render_registry
      iso_reg.should_not equal(iec_reg)
    end

    it "flavor registries are empty when no types registered" do
      # IecRenderer doesn't register any types; lookup finds them in IsoRenderer via ancestors
      Metanorma::Html::IecRenderer.render_registry.should be_empty
    end

    it "flavor renderer can register its own types independently" do
      # Simulate a new flavor registering a type
      flavor_class = Class.new(Metanorma::Html::IsoRenderer) do
        register_render String, :render_noop
      end
      flavor_class.render_registry.should have_key(String)
      Metanorma::Html::IsoRenderer.render_registry.should_not have_key(String)
    end
  end
end
