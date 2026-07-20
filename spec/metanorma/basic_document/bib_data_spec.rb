# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::BibData do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads BibData" do
      expect(defined?(Metanorma::Document::Components::BibData::BibData)).to be_truthy
    end

    it "autoloads BibDataExtensionType" do
      expect(defined?(Metanorma::Document::Components::BibData::BibDataExtensionType)).to be_truthy
    end

    it "autoloads BibliographicItem" do
      expect(defined?(Metanorma::Document::Components::BibData::BibliographicItem)).to be_truthy
    end

    it "autoloads DocumentType" do
      expect(defined?(Metanorma::Document::Components::BibData::DocumentType)).to be_truthy
    end
  end
end
