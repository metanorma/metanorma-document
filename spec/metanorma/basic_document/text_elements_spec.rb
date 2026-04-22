# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::TextElements do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads Asciiml" do
      defined?(Metanorma::Document::Components::TextElements::Asciiml).should be_truthy
    end

    it "autoloads EmphasisElement" do
      defined?(Metanorma::Document::Components::TextElements::EmphasisElement).should be_truthy
    end

    it "autoloads KeywordElement" do
      defined?(Metanorma::Document::Components::TextElements::KeywordElement).should be_truthy
    end

    it "autoloads Latex" do
      defined?(Metanorma::Document::Components::TextElements::Latex).should be_truthy
    end

    it "autoloads Mathml" do
      defined?(Metanorma::Document::Components::TextElements::Mathml).should be_truthy
    end

    it "autoloads MonospaceElement" do
      defined?(Metanorma::Document::Components::TextElements::MonospaceElement).should be_truthy
    end

    it "autoloads RubyElement" do
      defined?(Metanorma::Document::Components::TextElements::RubyElement).should be_truthy
    end

    it "autoloads SmallCapsElement" do
      defined?(Metanorma::Document::Components::TextElements::SmallCapsElement).should be_truthy
    end

    it "autoloads StemElement" do
      defined?(Metanorma::Document::Components::TextElements::StemElement).should be_truthy
    end

    it "autoloads StemType" do
      defined?(Metanorma::Document::Components::TextElements::StemType).should be_truthy
    end

    it "autoloads StemValue" do
      defined?(Metanorma::Document::Components::TextElements::StemValue).should be_truthy
    end

    it "autoloads StrikeElement" do
      defined?(Metanorma::Document::Components::TextElements::StrikeElement).should be_truthy
    end

    it "autoloads StrongElement" do
      defined?(Metanorma::Document::Components::TextElements::StrongElement).should be_truthy
    end

    it "autoloads SubscriptElement" do
      defined?(Metanorma::Document::Components::TextElements::SubscriptElement).should be_truthy
    end

    it "autoloads SuperscriptElement" do
      defined?(Metanorma::Document::Components::TextElements::SuperscriptElement).should be_truthy
    end

    it "autoloads TextElement" do
      defined?(Metanorma::Document::Components::TextElements::TextElement).should be_truthy
    end

    it "autoloads TextElementType" do
      defined?(Metanorma::Document::Components::TextElements::TextElementType).should be_truthy
    end

    it "autoloads UnderlineElement" do
      defined?(Metanorma::Document::Components::TextElements::UnderlineElement).should be_truthy
    end
  end
end
