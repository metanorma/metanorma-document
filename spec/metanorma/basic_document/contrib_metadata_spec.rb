# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::ContribMetadata do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads ContributionElementMetadata" do
      expect(defined?(Metanorma::Document::Components::ContribMetadata::ContributionElementMetadata)).to be_truthy
    end

    it "autoloads Hash" do
      expect(defined?(Metanorma::Document::Components::ContribMetadata::Hash)).to be_truthy
    end

    it "autoloads IntegrityValue" do
      expect(defined?(Metanorma::Document::Components::ContribMetadata::IntegrityValue)).to be_truthy
    end

    it "autoloads Iso10118Oid" do
      expect(defined?(Metanorma::Document::Components::ContribMetadata::Iso10118Oid)).to be_truthy
    end

    it "autoloads Iso14888Oid" do
      expect(defined?(Metanorma::Document::Components::ContribMetadata::Iso14888Oid)).to be_truthy
    end

    it "autoloads Signature" do
      expect(defined?(Metanorma::Document::Components::ContribMetadata::Signature)).to be_truthy
    end
  end
end
