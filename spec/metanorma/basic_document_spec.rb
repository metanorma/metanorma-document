# frozen_string_literal: true

RSpec.describe Metanorma::Document::Root do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  it "is a class" do
    described_class.class.should eq(Class)
  end

  it "inherits from Lutaml::Model::Serializable" do
    described_class.superclass.should eq(Lutaml::Model::Serializable)
  end

  describe "Components module" do
    it "is defined" do
      defined?(Metanorma::Document::Components).should be_truthy
    end

    it "autoloads AncillaryBlocks" do
      defined?(Metanorma::Document::Components::AncillaryBlocks).should be_truthy
    end

    it "autoloads BibData" do
      defined?(Metanorma::Document::Components::BibData).should be_truthy
    end

    it "autoloads Blocks" do
      defined?(Metanorma::Document::Components::Blocks).should be_truthy
    end

    it "autoloads Change" do
      defined?(Metanorma::Document::Components::Change).should be_truthy
    end

    it "autoloads ContribMetadata" do
      defined?(Metanorma::Document::Components::ContribMetadata).should be_truthy
    end

    it "autoloads DataTypes" do
      defined?(Metanorma::Document::Components::DataTypes).should be_truthy
    end

    it "autoloads EmptyElements" do
      defined?(Metanorma::Document::Components::EmptyElements).should be_truthy
    end

    it "autoloads IdElements" do
      defined?(Metanorma::Document::Components::IdElements).should be_truthy
    end

    it "autoloads Lists" do
      defined?(Metanorma::Document::Components::Lists).should be_truthy
    end

    it "autoloads MultiParagraph" do
      defined?(Metanorma::Document::Components::MultiParagraph).should be_truthy
    end

    it "autoloads Paragraphs" do
      defined?(Metanorma::Document::Components::Paragraphs).should be_truthy
    end

    it "autoloads ReferenceElements" do
      defined?(Metanorma::Document::Components::ReferenceElements).should be_truthy
    end

    it "autoloads Sections" do
      defined?(Metanorma::Document::Components::Sections).should be_truthy
    end

    it "autoloads Tables" do
      defined?(Metanorma::Document::Components::Tables).should be_truthy
    end

    it "autoloads TextElements" do
      defined?(Metanorma::Document::Components::TextElements).should be_truthy
    end
  end
end
