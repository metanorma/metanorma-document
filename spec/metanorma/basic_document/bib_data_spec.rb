# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::BibData do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads BibData" do
      defined?(Metanorma::Document::Components::BibData::BibData).should be_truthy
    end

    it "autoloads BibDataExtensionType" do
      defined?(Metanorma::Document::Components::BibData::BibDataExtensionType).should be_truthy
    end

    it "autoloads BibliographicItem" do
      defined?(Metanorma::Document::Components::BibData::BibliographicItem).should be_truthy
    end

    it "autoloads DocumentType" do
      defined?(Metanorma::Document::Components::BibData::DocumentType).should be_truthy
    end
  end
end
