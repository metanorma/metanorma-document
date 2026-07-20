# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Lists do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads Definition" do
      expect(defined?(Metanorma::Document::Components::Lists::Definition)).to be_truthy
    end

    it "autoloads DefinitionList" do
      expect(defined?(Metanorma::Document::Components::Lists::DefinitionList)).to be_truthy
    end

    it "autoloads List" do
      expect(defined?(Metanorma::Document::Components::Lists::List)).to be_truthy
    end

    it "autoloads OrderedList" do
      expect(defined?(Metanorma::Document::Components::Lists::OrderedList)).to be_truthy
    end

    it "autoloads OrderedListType" do
      expect(defined?(Metanorma::Document::Components::Lists::OrderedListType)).to be_truthy
    end

    it "autoloads UnorderedList" do
      expect(defined?(Metanorma::Document::Components::Lists::UnorderedList)).to be_truthy
    end
  end
end
