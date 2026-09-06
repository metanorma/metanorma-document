# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso/document"

RSpec.describe Metanorma::Mirror::DefaultRegistry do
  describe ".build" do
    it "returns a HandlerRegistry instance" do
      registry = described_class.build
      expect(registry).to be_a(Metanorma::Mirror::HandlerRegistry)
    end

    it "returns a fresh registry each call (no mutation leak)" do
      first = described_class.build
      second = described_class.build
      expect(first).not_to equal(second)

      handler_mod = Module.new do
        def self.call(_element, context:); end
      end
      custom_klass = Class.new
      first.register(custom_klass, handler_mod)

      expect(second.registered?(custom_klass)).to be(false)
    end

    it "registers paragraph handler" do
      registry = described_class.build
      expect(registry.registered?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)).to be(true)
    end

    it "registers section handlers" do
      registry = described_class.build
      [
        Metanorma::Standoc::Document::Sections::ClauseSection,
        Metanorma::Standoc::Document::Sections::AnnexSection,
      ].each do |klass|
        expect(registry.registered?(klass)).to be(true)
      end
    end

    it "registers block handlers for tables, figures, notes" do
      registry = described_class.build
      [
        Metanorma::Document::Components::Tables::TableBlock,
        Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
        Metanorma::Document::Components::Blocks::NoteBlock,
      ].each do |klass|
        expect(registry.registered?(klass)).to be(true)
      end
    end

    it "registers list handlers" do
      registry = described_class.build
      [
        Metanorma::Document::Components::Lists::UnorderedList,
        Metanorma::Document::Components::Lists::OrderedList,
        Metanorma::Document::Components::Lists::DefinitionList,
      ].each do |klass|
        expect(registry.registered?(klass)).to be(true)
      end
    end

    it "registers structural handlers" do
      registry = described_class.build
      [
        Metanorma::Standoc::Document::Sections::Preface,
        Metanorma::Standoc::Document::Sections::Sections,
        Metanorma::Standoc::Document::Sections::BibliographySection,
      ].each do |klass|
        expect(registry.registered?(klass)).to be(true)
      end
    end
  end
end
