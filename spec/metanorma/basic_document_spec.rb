# frozen_string_literal: true

RSpec.describe Metanorma::Document::Root do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  it "is a class" do
    expect(described_class.class).to eq(Class)
  end

  it "inherits from Lutaml::Model::Serializable" do
    expect(described_class.superclass).to eq(Lutaml::Model::Serializable)
  end

  describe "Components module" do
    it "is defined" do
      expect(defined?(Metanorma::Document::Components)).to be_truthy
    end

    it "autoloads AncillaryBlocks" do
      expect(defined?(Metanorma::Document::Components::AncillaryBlocks)).to be_truthy
    end

    it "autoloads BibData" do
      expect(defined?(Metanorma::Document::Components::BibData)).to be_truthy
    end

    it "autoloads Blocks" do
      expect(defined?(Metanorma::Document::Components::Blocks)).to be_truthy
    end

    it "autoloads Change" do
      expect(defined?(Metanorma::Document::Components::Change)).to be_truthy
    end

    it "autoloads ContribMetadata" do
      expect(defined?(Metanorma::Document::Components::ContribMetadata)).to be_truthy
    end

    it "autoloads DataTypes" do
      expect(defined?(Metanorma::Document::Components::DataTypes)).to be_truthy
    end

    it "autoloads EmptyElements" do
      expect(defined?(Metanorma::Document::Components::EmptyElements)).to be_truthy
    end

    it "autoloads IdElements" do
      expect(defined?(Metanorma::Document::Components::IdElements)).to be_truthy
    end

    it "autoloads Lists" do
      expect(defined?(Metanorma::Document::Components::Lists)).to be_truthy
    end

    it "autoloads MultiParagraph" do
      expect(defined?(Metanorma::Document::Components::MultiParagraph)).to be_truthy
    end

    it "autoloads Paragraphs" do
      expect(defined?(Metanorma::Document::Components::Paragraphs)).to be_truthy
    end

    it "autoloads ReferenceElements" do
      expect(defined?(Metanorma::Document::Components::ReferenceElements)).to be_truthy
    end

    it "autoloads Sections" do
      expect(defined?(Metanorma::Document::Components::Sections)).to be_truthy
    end

    it "autoloads Tables" do
      expect(defined?(Metanorma::Document::Components::Tables)).to be_truthy
    end

    it "autoloads TextElements" do
      expect(defined?(Metanorma::Document::Components::TextElements)).to be_truthy
    end
  end
end
