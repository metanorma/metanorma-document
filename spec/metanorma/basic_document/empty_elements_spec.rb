# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::EmptyElements do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads BasicElement" do
      expect(defined?(Metanorma::Document::Components::EmptyElements::BasicElement)).to be_truthy
    end

    it "autoloads HorizontalRuleElement" do
      expect(defined?(Metanorma::Document::Components::EmptyElements::HorizontalRuleElement)).to be_truthy
    end

    it "autoloads IndexElement" do
      expect(defined?(Metanorma::Document::Components::EmptyElements::IndexElement)).to be_truthy
    end

    it "autoloads LineBreakElement" do
      expect(defined?(Metanorma::Document::Components::EmptyElements::LineBreakElement)).to be_truthy
    end

    it "autoloads PageBreakElement" do
      expect(defined?(Metanorma::Document::Components::EmptyElements::PageBreakElement)).to be_truthy
    end
  end
end
