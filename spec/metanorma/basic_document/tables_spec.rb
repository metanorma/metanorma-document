# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Tables do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads ParagraphTableCell" do
      expect(defined?(Metanorma::Document::Components::Tables::ParagraphTableCell)).to be_truthy
    end

    it "autoloads TableBlock" do
      expect(defined?(Metanorma::Document::Components::Tables::TableBlock)).to be_truthy
    end

    it "autoloads TableCell" do
      expect(defined?(Metanorma::Document::Components::Tables::TableCell)).to be_truthy
    end

    it "autoloads TextAlignment" do
      expect(defined?(Metanorma::Document::Components::Tables::TextAlignment)).to be_truthy
    end

    it "autoloads TextTableCell" do
      expect(defined?(Metanorma::Document::Components::Tables::TextTableCell)).to be_truthy
    end

    it "autoloads TextTableRow" do
      expect(defined?(Metanorma::Document::Components::Tables::TextTableRow)).to be_truthy
    end

    it "autoloads VerticalAlignment" do
      expect(defined?(Metanorma::Document::Components::Tables::VerticalAlignment)).to be_truthy
    end
  end
end
