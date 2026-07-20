# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Change do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads AttributeChangeAction" do
      expect(defined?(Metanorma::Document::Components::Change::AttributeChangeAction)).to be_truthy
    end

    it "autoloads AttributeModify" do
      expect(defined?(Metanorma::Document::Components::Change::AttributeModify)).to be_truthy
    end

    it "autoloads Change" do
      expect(defined?(Metanorma::Document::Components::Change::Change)).to be_truthy
    end

    it "autoloads ChangeSet" do
      expect(defined?(Metanorma::Document::Components::Change::ChangeSet)).to be_truthy
    end

    it "autoloads ContentAction" do
      expect(defined?(Metanorma::Document::Components::Change::ContentAction)).to be_truthy
    end

    it "autoloads ContentChange" do
      expect(defined?(Metanorma::Document::Components::Change::ContentChange)).to be_truthy
    end

    it "autoloads ContentChangeAction" do
      expect(defined?(Metanorma::Document::Components::Change::ContentChangeAction)).to be_truthy
    end

    it "autoloads ContentModify" do
      expect(defined?(Metanorma::Document::Components::Change::ContentModify)).to be_truthy
    end

    it "autoloads NodeChange" do
      expect(defined?(Metanorma::Document::Components::Change::NodeChange)).to be_truthy
    end

    it "autoloads NodeDelete" do
      expect(defined?(Metanorma::Document::Components::Change::NodeDelete)).to be_truthy
    end

    it "autoloads NodeInsert" do
      expect(defined?(Metanorma::Document::Components::Change::NodeInsert)).to be_truthy
    end

    it "autoloads NodeMove" do
      expect(defined?(Metanorma::Document::Components::Change::NodeMove)).to be_truthy
    end

    it "autoloads UniqueIdentifier" do
      expect(defined?(Metanorma::Document::Components::Change::UniqueIdentifier)).to be_truthy
    end
  end
end
