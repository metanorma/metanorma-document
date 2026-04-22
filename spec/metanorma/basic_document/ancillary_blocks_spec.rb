# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::AncillaryBlocks do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads ExampleBlock" do
      defined?(Metanorma::Document::Components::AncillaryBlocks::ExampleBlock).should be_truthy
    end

    it "autoloads FigureBlock" do
      defined?(Metanorma::Document::Components::AncillaryBlocks::FigureBlock).should be_truthy
    end

    it "autoloads FormulaBlock" do
      defined?(Metanorma::Document::Components::AncillaryBlocks::FormulaBlock).should be_truthy
    end

    it "autoloads LiteralBlock" do
      defined?(Metanorma::Document::Components::AncillaryBlocks::LiteralBlock).should be_truthy
    end

    it "autoloads SourcecodeBlock" do
      defined?(Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock).should be_truthy
    end

    it "autoloads Subfigure" do
      defined?(Metanorma::Document::Components::AncillaryBlocks::Subfigure).should be_truthy
    end
  end
end
