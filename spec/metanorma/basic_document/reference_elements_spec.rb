# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::ReferenceElements do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads Callout" do
      defined?(Metanorma::Document::Components::ReferenceElements::Callout).should be_truthy
    end

    it "autoloads Citation" do
      defined?(Metanorma::Document::Components::ReferenceElements::Citation).should be_truthy
    end

    it "autoloads Footnote" do
      defined?(Metanorma::Document::Components::ReferenceElements::Footnote).should be_truthy
    end

    it "autoloads IndexXrefElement" do
      defined?(Metanorma::Document::Components::ReferenceElements::IndexXrefElement).should be_truthy
    end

    it "autoloads ReferenceElement" do
      defined?(Metanorma::Document::Components::ReferenceElements::ReferenceElement).should be_truthy
    end

    it "autoloads ReferenceFormat" do
      defined?(Metanorma::Document::Components::ReferenceElements::ReferenceFormat).should be_truthy
    end

    it "autoloads ReferenceToCitationElement" do
      defined?(Metanorma::Document::Components::ReferenceElements::ReferenceToCitationElement).should be_truthy
    end

    it "autoloads ReferenceToIdElement" do
      defined?(Metanorma::Document::Components::ReferenceElements::ReferenceToIdElement).should be_truthy
    end

    it "autoloads ReferenceToIdWithParagraphElement" do
      defined?(Metanorma::Document::Components::ReferenceElements::ReferenceToIdWithParagraphElement).should be_truthy
    end

    it "autoloads ReferenceToLinkElement" do
      defined?(Metanorma::Document::Components::ReferenceElements::ReferenceToLinkElement).should be_truthy
    end
  end
end
