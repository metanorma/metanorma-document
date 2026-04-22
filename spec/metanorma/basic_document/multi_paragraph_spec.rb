# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::MultiParagraph do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads AdmonitionBlock" do
      defined?(Metanorma::Document::Components::MultiParagraph::AdmonitionBlock).should be_truthy
    end

    it "autoloads AdmonitionType" do
      defined?(Metanorma::Document::Components::MultiParagraph::AdmonitionType).should be_truthy
    end

    it "autoloads ParagraphsBlock" do
      defined?(Metanorma::Document::Components::MultiParagraph::ParagraphsBlock).should be_truthy
    end

    it "autoloads QuoteBlock" do
      defined?(Metanorma::Document::Components::MultiParagraph::QuoteBlock).should be_truthy
    end

    it "autoloads ReviewBlock" do
      defined?(Metanorma::Document::Components::MultiParagraph::ReviewBlock).should be_truthy
    end
  end
end
