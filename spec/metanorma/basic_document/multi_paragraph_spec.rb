# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::MultiParagraph do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads AdmonitionBlock" do
      expect(defined?(Metanorma::Document::Components::MultiParagraph::AdmonitionBlock)).to be_truthy
    end

    it "autoloads AdmonitionType" do
      expect(defined?(Metanorma::Document::Components::MultiParagraph::AdmonitionType)).to be_truthy
    end

    it "autoloads ParagraphsBlock" do
      expect(defined?(Metanorma::Document::Components::MultiParagraph::ParagraphsBlock)).to be_truthy
    end

    it "autoloads QuoteBlock" do
      expect(defined?(Metanorma::Document::Components::MultiParagraph::QuoteBlock)).to be_truthy
    end

    it "autoloads ReviewBlock" do
      expect(defined?(Metanorma::Document::Components::MultiParagraph::ReviewBlock)).to be_truthy
    end
  end
end
