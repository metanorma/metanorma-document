# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::ReferenceElements do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads Callout" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements::Callout)).to be_truthy
    end

    it "autoloads Citation" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements::Citation)).to be_truthy
    end

    it "autoloads Footnote" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements::Footnote)).to be_truthy
    end

    it "autoloads IndexXrefElement" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements::IndexXrefElement)).to be_truthy
    end

    it "autoloads ReferenceElement" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements::ReferenceElement)).to be_truthy
    end

    it "autoloads ReferenceFormat" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements::ReferenceFormat)).to be_truthy
    end

    it "autoloads ReferenceToCitationElement" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements::ReferenceToCitationElement)).to be_truthy
    end

    it "autoloads ReferenceToIdElement" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements::ReferenceToIdElement)).to be_truthy
    end

    it "autoloads ReferenceToIdWithParagraphElement" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements::ReferenceToIdWithParagraphElement)).to be_truthy
    end

    it "autoloads ReferenceToLinkElement" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements::ReferenceToLinkElement)).to be_truthy
    end
  end
end
