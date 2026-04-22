# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Change do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads AttributeChangeAction" do
      defined?(Metanorma::Document::Components::Change::AttributeChangeAction).should be_truthy
    end

    it "autoloads AttributeModify" do
      defined?(Metanorma::Document::Components::Change::AttributeModify).should be_truthy
    end

    it "autoloads Change" do
      defined?(Metanorma::Document::Components::Change::Change).should be_truthy
    end

    it "autoloads ChangeSet" do
      defined?(Metanorma::Document::Components::Change::ChangeSet).should be_truthy
    end

    it "autoloads ContentAction" do
      defined?(Metanorma::Document::Components::Change::ContentAction).should be_truthy
    end

    it "autoloads ContentChange" do
      defined?(Metanorma::Document::Components::Change::ContentChange).should be_truthy
    end

    it "autoloads ContentChangeAction" do
      defined?(Metanorma::Document::Components::Change::ContentChangeAction).should be_truthy
    end

    it "autoloads ContentModify" do
      defined?(Metanorma::Document::Components::Change::ContentModify).should be_truthy
    end

    it "autoloads NodeChange" do
      defined?(Metanorma::Document::Components::Change::NodeChange).should be_truthy
    end

    it "autoloads NodeDelete" do
      defined?(Metanorma::Document::Components::Change::NodeDelete).should be_truthy
    end

    it "autoloads NodeInsert" do
      defined?(Metanorma::Document::Components::Change::NodeInsert).should be_truthy
    end

    it "autoloads NodeMove" do
      defined?(Metanorma::Document::Components::Change::NodeMove).should be_truthy
    end

    it "autoloads UniqueIdentifier" do
      defined?(Metanorma::Document::Components::Change::UniqueIdentifier).should be_truthy
    end
  end
end
