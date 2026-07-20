# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::TextElements do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads Asciiml" do
      expect(defined?(Metanorma::Document::Components::TextElements::Asciiml)).to be_truthy
    end

    it "autoloads EmphasisElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::EmphasisElement)).to be_truthy
    end

    it "autoloads KeywordElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::KeywordElement)).to be_truthy
    end

    it "autoloads Latex" do
      expect(defined?(Metanorma::Document::Components::TextElements::Latex)).to be_truthy
    end

    it "parses math element via mml gem" do
      xml = <<~XML
        <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mrow><mi>x</mi></mrow></math></stem>
      XML
      stem = Metanorma::Document::Components::TextElements::StemElement.from_xml(xml)
      expect(stem.stem_type).to eq("MathML")
      expect(stem.math).to be_a(Mml::V3::Math)
    end

    it "autoloads MonospaceElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::MonospaceElement)).to be_truthy
    end

    it "autoloads RubyElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::RubyElement)).to be_truthy
    end

    it "autoloads SmallCapsElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::SmallCapsElement)).to be_truthy
    end

    it "autoloads StemElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::StemElement)).to be_truthy
    end

    it "autoloads StemType" do
      expect(defined?(Metanorma::Document::Components::TextElements::StemType)).to be_truthy
    end

    it "autoloads StemValue" do
      expect(defined?(Metanorma::Document::Components::TextElements::StemValue)).to be_truthy
    end

    it "autoloads StrikeElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::StrikeElement)).to be_truthy
    end

    it "autoloads StrongElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::StrongElement)).to be_truthy
    end

    it "autoloads SubscriptElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::SubscriptElement)).to be_truthy
    end

    it "autoloads SuperscriptElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::SuperscriptElement)).to be_truthy
    end

    it "autoloads TextElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::TextElement)).to be_truthy
    end

    it "autoloads TextElementType" do
      expect(defined?(Metanorma::Document::Components::TextElements::TextElementType)).to be_truthy
    end

    it "autoloads UnderlineElement" do
      expect(defined?(Metanorma::Document::Components::TextElements::UnderlineElement)).to be_truthy
    end
  end
end
