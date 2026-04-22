# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Sections do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads BasicSection" do
      defined?(Metanorma::Document::Components::Sections::BasicSection).should be_truthy
    end

    it "autoloads ContentSection" do
      defined?(Metanorma::Document::Components::Sections::ContentSection).should be_truthy
    end

    it "autoloads HierarchicalSection" do
      defined?(Metanorma::Document::Components::Sections::HierarchicalSection).should be_truthy
    end

    it "autoloads ReferencesSection" do
      defined?(Metanorma::Document::Components::Sections::ReferencesSection).should be_truthy
    end
  end
end
