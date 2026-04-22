# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Paragraphs do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads ParagraphBlock" do
      defined?(Metanorma::Document::Components::Paragraphs::ParagraphBlock).should be_truthy
    end

    it "autoloads ParagraphWithFootnote" do
      defined?(Metanorma::Document::Components::Paragraphs::ParagraphWithFootnote).should be_truthy
    end

    it "autoloads TextAlignment" do
      defined?(Metanorma::Document::Components::Paragraphs::TextAlignment).should be_truthy
    end
  end
end
