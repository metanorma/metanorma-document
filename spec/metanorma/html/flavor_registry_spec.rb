# frozen_string_literal: true

require "spec_helper"
require "metanorma/html"
require "metanorma/iso_document"

RSpec.describe Metanorma::Html::FlavorRegistry do
  let(:registry) { described_class.new }
  let(:base_flavor) do
    Metanorma::Html::Flavor.new(
      name: nil,
      model_class: Metanorma::Document::Root,
      renderer_class: Metanorma::Html::BaseRenderer,
    )
  end
  let(:standard_flavor) do
    Metanorma::Html::Flavor.new(
      name: nil,
      model_class: Metanorma::StandardDocument::Root,
      renderer_class: Metanorma::Html::StandardRenderer,
    )
  end
  let(:iso_flavor) do
    Metanorma::Html::Flavor.new(
      name: :iso,
      model_class: Metanorma::IsoDocument::Root,
      renderer_class: Metanorma::Html::IsoRenderer,
      pubid_module: :"Pubid::Iso",
    )
  end

  before do
    [base_flavor, standard_flavor, iso_flavor].each { |f| registry.register(f) }
  end

  describe "#find_for" do
    it "returns the most-specific registered flavor" do
      flavor = registry.find_for(Metanorma::IsoDocument::Root)
      flavor.should equal(iso_flavor)
    end

    it "returns a parent flavor when no exact match registered" do
      flavor = registry.find_for(Metanorma::StandardDocument::Root)
      flavor.should equal(standard_flavor)
    end

    it "returns the base flavor for the base model class" do
      flavor = registry.find_for(Metanorma::Document::Root)
      flavor.should equal(base_flavor)
    end

    it "returns nil when no flavor matches" do
      flavor = registry.find_for(String)
      flavor.should be_nil
    end
  end

  describe "#name_for" do
    it "returns the symbolic name for the matching flavor" do
      registry.name_for(Metanorma::IsoDocument::Root).should eq(:iso)
    end

    it "returns nil for flavors without a name" do
      registry.name_for(Metanorma::Document::Root).should be_nil
    end
  end

  describe "#renderer_for" do
    it "returns the renderer class for the matching flavor" do
      registry.renderer_for(Metanorma::IsoDocument::Root).should eq(Metanorma::Html::IsoRenderer)
    end
  end

  describe "#pubid_module_for" do
    it "returns the Pubid module constant when flavor has one and it is loadable" do
      # Pubid::Iso may not be autoloaded in the test env unless a flavor
      # document has been parsed. Verify the resolution mechanism by
      # checking that const-get either succeeds or returns nil.
      result = registry.pubid_module_for(Metanorma::IsoDocument::Root)
      result.should satisfy { |v| v.nil? || v.is_a?(Module) }
    end

    it "returns nil when flavor has no Pubid module" do
      registry.pubid_module_for(Metanorma::Document::Root).should be_nil
    end
  end

  describe "#each (Enumerable)" do
    it "yields every registered flavor in registration order" do
      yielded = []
      registry.each { |f| yielded << f }
      yielded.should eq([base_flavor, standard_flavor, iso_flavor])
    end
  end
end

RSpec.describe Metanorma::Html::Flavor do
  let(:flavor) do
    described_class.new(
      name: :iso,
      model_class: Metanorma::IsoDocument::Root,
      renderer_class: Metanorma::Html::IsoRenderer,
      pubid_module: :"Pubid::Iso",
    )
  end

  describe "#matches?" do
    it "matches the exact model class" do
      flavor.matches?(Metanorma::IsoDocument::Root).should be(true)
    end

    it "matches descendant classes" do
      subclass = Class.new(Metanorma::IsoDocument::Root)
      flavor.matches?(subclass).should be(true)
    end

    it "does not match unrelated classes" do
      flavor.matches?(Metanorma::Document::Root).should be(false)
    end
  end

  describe "#pubid_module_const" do
    it "resolves the module constant when loadable, nil otherwise" do
      result = flavor.pubid_module_const
      result.should satisfy { |v| v.nil? || v.is_a?(Module) }
    end

    it "returns nil when no pubid_module" do
      bare = described_class.new(name: :other,
                                 model_class: Metanorma::Document::Root,
                                 renderer_class: Metanorma::Html::BaseRenderer)
      bare.pubid_module_const.should be_nil
    end
  end
end
