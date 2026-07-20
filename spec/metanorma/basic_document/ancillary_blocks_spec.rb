# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::AncillaryBlocks do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads ExampleBlock" do
      expect(defined?(Metanorma::Document::Components::AncillaryBlocks::ExampleBlock)).to be_truthy
    end

    it "autoloads FigureBlock" do
      expect(defined?(Metanorma::Document::Components::AncillaryBlocks::FigureBlock)).to be_truthy
    end

    it "autoloads FormulaBlock" do
      expect(defined?(Metanorma::Document::Components::AncillaryBlocks::FormulaBlock)).to be_truthy
    end

    it "autoloads LiteralBlock" do
      expect(defined?(Metanorma::Document::Components::AncillaryBlocks::LiteralBlock)).to be_truthy
    end

    it "autoloads SourcecodeBlock" do
      expect(defined?(Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock)).to be_truthy
    end

    it "autoloads Subfigure" do
      expect(defined?(Metanorma::Document::Components::AncillaryBlocks::Subfigure)).to be_truthy
    end
  end
end
