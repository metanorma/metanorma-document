# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Paragraphs do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads ParagraphBlock" do
      expect(defined?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)).to be_truthy
    end

    it "autoloads ParagraphWithFootnote" do
      expect(defined?(Metanorma::Document::Components::Paragraphs::ParagraphWithFootnote)).to be_truthy
    end

    it "autoloads TextAlignment" do
      expect(defined?(Metanorma::Document::Components::Paragraphs::TextAlignment)).to be_truthy
    end
  end
end
