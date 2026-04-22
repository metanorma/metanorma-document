# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Lists do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads Definition" do
      defined?(Metanorma::Document::Components::Lists::Definition).should be_truthy
    end

    it "autoloads DefinitionList" do
      defined?(Metanorma::Document::Components::Lists::DefinitionList).should be_truthy
    end

    it "autoloads List" do
      defined?(Metanorma::Document::Components::Lists::List).should be_truthy
    end

    it "autoloads OrderedList" do
      defined?(Metanorma::Document::Components::Lists::OrderedList).should be_truthy
    end

    it "autoloads OrderedListType" do
      defined?(Metanorma::Document::Components::Lists::OrderedListType).should be_truthy
    end

    it "autoloads UnorderedList" do
      defined?(Metanorma::Document::Components::Lists::UnorderedList).should be_truthy
    end
  end
end
