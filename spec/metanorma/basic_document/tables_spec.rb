# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Tables do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads ParagraphTableCell" do
      defined?(Metanorma::Document::Components::Tables::ParagraphTableCell).should be_truthy
    end

    it "autoloads TableBlock" do
      defined?(Metanorma::Document::Components::Tables::TableBlock).should be_truthy
    end

    it "autoloads TableCell" do
      defined?(Metanorma::Document::Components::Tables::TableCell).should be_truthy
    end

    it "autoloads TextAlignment" do
      defined?(Metanorma::Document::Components::Tables::TextAlignment).should be_truthy
    end

    it "autoloads TextTableCell" do
      defined?(Metanorma::Document::Components::Tables::TextTableCell).should be_truthy
    end

    it "autoloads TextTableRow" do
      defined?(Metanorma::Document::Components::Tables::TextTableRow).should be_truthy
    end

    it "autoloads VerticalAlignment" do
      defined?(Metanorma::Document::Components::Tables::VerticalAlignment).should be_truthy
    end
  end
end
