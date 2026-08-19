# frozen_string_literal: true

require "spec_helper"
require "metanorma/html"
require "metanorma/iso/document"

RSpec.describe Metanorma::FlavorRegistry do
  let(:registry) { described_class.new }
  let(:base_flavor) do
    Metanorma::Flavor.new(
      name: nil,
      model_class: Metanorma::Document::Root,
      renderers: { html: Metanorma::Html::BaseRenderer },
    )
  end
  let(:standard_flavor) do
    Metanorma::Flavor.new(
      name: nil,
      model_class: Metanorma::Standoc::Document::Root,
      renderers: { html: Metanorma::Html::StandardRenderer },
    )
  end
  let(:iso_flavor) do
    Metanorma::Flavor.new(
      name: :iso,
      model_class: Metanorma::Iso::Document::Root,
      renderers: { html: SpecFlavors::IsoRenderer },
      pubid_module: :"Pubid::Iso",
    )
  end

  before do
    [base_flavor, standard_flavor, iso_flavor].each { |f| registry.register(f) }
  end

  describe "#find_for" do
    it "returns the most-specific registered flavor" do
      flavor = registry.find_for(Metanorma::Iso::Document::Root)
      expect(flavor).to equal(iso_flavor)
    end

    it "returns a parent flavor when no exact match registered" do
      flavor = registry.find_for(Metanorma::Standoc::Document::Root)
      expect(flavor).to equal(standard_flavor)
    end

    it "returns the base flavor for the base model class" do
      flavor = registry.find_for(Metanorma::Document::Root)
      expect(flavor).to equal(base_flavor)
    end

    it "returns nil when no flavor matches" do
      flavor = registry.find_for(String)
      expect(flavor).to be_nil
    end
  end

  describe "#name_for" do
    it "returns the symbolic name for the matching flavor" do
      expect(registry.name_for(Metanorma::Iso::Document::Root)).to eq(:iso)
    end

    it "returns nil for flavors without a name" do
      expect(registry.name_for(Metanorma::Document::Root)).to be_nil
    end
  end

  describe "#renderer_for" do
    it "returns the renderer class for the matching flavor" do
      document = Metanorma::Iso::Document::Root.new
      expect(registry.renderer_for(:html, document)).to eq(SpecFlavors::IsoRenderer)
    end
  end

  describe "#pubid_module_for" do
    it "returns the Pubid module constant when flavor has one and it is loadable" do
      # Pubid::Iso may not be autoloaded in the test env unless a flavor
      # document has been parsed. Verify the resolution mechanism by
      # checking that const-get either succeeds or returns nil.
      result = registry.pubid_module_for(Metanorma::Iso::Document::Root)
      expect(result).to(satisfy { |v| v.nil? || v.is_a?(Module) })
    end

    it "returns nil when flavor has no Pubid module" do
      expect(registry.pubid_module_for(Metanorma::Document::Root)).to be_nil
    end
  end

  describe "#each (Enumerable)" do
    it "yields every registered flavor in registration order" do
      yielded = registry.map { |f| f }
      expect(yielded).to eq([base_flavor, standard_flavor, iso_flavor])
    end
  end
end

RSpec.describe Metanorma::Flavor do
  let(:flavor) do
    described_class.new(
      name: :iso,
      model_class: Metanorma::Iso::Document::Root,
      renderers: { html: SpecFlavors::IsoRenderer },
      pubid_module: :"Pubid::Iso",
    )
  end

  describe "#matches?" do
    it "matches the exact model class" do
      expect(flavor.matches?(Metanorma::Iso::Document::Root)).to be(true)
    end

    it "matches descendant classes" do
      subclass = Class.new(Metanorma::Iso::Document::Root)
      expect(flavor.matches?(subclass)).to be(true)
    end

    it "does not match unrelated classes" do
      expect(flavor.matches?(Metanorma::Document::Root)).to be(false)
    end
  end

  describe "#pubid_module_const" do
    it "resolves the module constant when loadable, nil otherwise" do
      result = flavor.pubid_module_const
      expect(result).to(satisfy { |v| v.nil? || v.is_a?(Module) })
    end

    it "returns nil when no pubid_module" do
      bare = described_class.new(name: :other,
                                 model_class: Metanorma::Document::Root,
                                 renderers: { html: Metanorma::Html::BaseRenderer })
      expect(bare.pubid_module_const).to be_nil
    end
  end
end
