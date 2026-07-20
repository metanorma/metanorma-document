# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Sections do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads BasicSection" do
      expect(defined?(Metanorma::Document::Components::Sections::BasicSection)).to be_truthy
    end

    it "autoloads ContentSection" do
      expect(defined?(Metanorma::Document::Components::Sections::ContentSection)).to be_truthy
    end

    it "autoloads HierarchicalSection" do
      expect(defined?(Metanorma::Document::Components::Sections::HierarchicalSection)).to be_truthy
    end

    it "autoloads ReferencesSection" do
      expect(defined?(Metanorma::Document::Components::Sections::ReferencesSection)).to be_truthy
    end
  end
end
