# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::EmptyElements do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads BasicElement" do
      defined?(Metanorma::Document::Components::EmptyElements::BasicElement).should be_truthy
    end

    it "autoloads HorizontalRuleElement" do
      defined?(Metanorma::Document::Components::EmptyElements::HorizontalRuleElement).should be_truthy
    end

    it "autoloads IndexElement" do
      defined?(Metanorma::Document::Components::EmptyElements::IndexElement).should be_truthy
    end

    it "autoloads LineBreakElement" do
      defined?(Metanorma::Document::Components::EmptyElements::LineBreakElement).should be_truthy
    end

    it "autoloads PageBreakElement" do
      defined?(Metanorma::Document::Components::EmptyElements::PageBreakElement).should be_truthy
    end
  end
end
