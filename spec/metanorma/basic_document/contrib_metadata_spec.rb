# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::ContribMetadata do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads ContributionElementMetadata" do
      defined?(Metanorma::Document::Components::ContribMetadata::ContributionElementMetadata).should be_truthy
    end

    it "autoloads Hash" do
      defined?(Metanorma::Document::Components::ContribMetadata::Hash).should be_truthy
    end

    it "autoloads IntegrityValue" do
      defined?(Metanorma::Document::Components::ContribMetadata::IntegrityValue).should be_truthy
    end

    it "autoloads Iso10118Oid" do
      defined?(Metanorma::Document::Components::ContribMetadata::Iso10118Oid).should be_truthy
    end

    it "autoloads Iso14888Oid" do
      defined?(Metanorma::Document::Components::ContribMetadata::Iso14888Oid).should be_truthy
    end

    it "autoloads Signature" do
      defined?(Metanorma::Document::Components::ContribMetadata::Signature).should be_truthy
    end
  end
end
