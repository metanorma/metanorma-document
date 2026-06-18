# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso_document"

RSpec.describe Metanorma::Mirror::DefaultRegistry do
  describe ".build" do
    it "returns a HandlerRegistry instance" do
      registry = described_class.build
      registry.should be_a(Metanorma::Mirror::HandlerRegistry)
    end

    it "returns a fresh registry each call (no mutation leak)" do
      first = described_class.build
      second = described_class.build
      first.should_not equal(second)

      handler_mod = Module.new do
        def self.call(_element, context:); end
      end
      custom_klass = Class.new
      first.register(custom_klass, handler_mod)

      second.registered?(custom_klass).should be(false)
    end

    it "registers paragraph handler" do
      registry = described_class.build
      registry.registered?(Metanorma::Document::Components::Paragraphs::ParagraphBlock).should be(true)
    end

    it "registers section handlers" do
      registry = described_class.build
      [
        Metanorma::StandardDocument::Sections::ClauseSection,
        Metanorma::StandardDocument::Sections::AnnexSection,
      ].each do |klass|
        registry.registered?(klass).should be(true)
      end
    end

    it "registers block handlers for tables, figures, notes" do
      registry = described_class.build
      [
        Metanorma::Document::Components::Tables::TableBlock,
        Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
        Metanorma::Document::Components::Blocks::NoteBlock,
      ].each do |klass|
        registry.registered?(klass).should be(true)
      end
    end

    it "registers list handlers" do
      registry = described_class.build
      [
        Metanorma::Document::Components::Lists::UnorderedList,
        Metanorma::Document::Components::Lists::OrderedList,
        Metanorma::Document::Components::Lists::DefinitionList,
      ].each do |klass|
        registry.registered?(klass).should be(true)
      end
    end

    it "registers structural handlers" do
      registry = described_class.build
      [
        Metanorma::StandardDocument::Sections::Preface,
        Metanorma::StandardDocument::Sections::Sections,
        Metanorma::StandardDocument::Sections::BibliographySection,
      ].each do |klass|
        registry.registered?(klass).should be(true)
      end
    end
  end
end
