# frozen_string_literal: true

require "spec_helper"
require "metanorma/document"

RSpec.describe "BUGS.sts 07: Math element type split" do
  describe Metanorma::Document::Components::Inline::SemanticMathElement do
    it "is a subclass of MathElement" do
      described_class.ancestors.should include(Metanorma::Document::Components::Inline::MathElement)
    end

    it "round-trips through XML" do
      m = described_class.from_xml(<<~XML)
        <math xmlns="http://www.w3.org/1998/Math/MathML"><mn>0.7</mn></math>
      XML
      m.content.should include("0.7")
    end
  end

  describe Metanorma::Document::Components::Inline::RenderedMathElement do
    it "is a subclass of MathElement" do
      described_class.ancestors.should include(Metanorma::Document::Components::Inline::MathElement)
    end

    it "round-trips through XML" do
      m = described_class.from_xml(<<~XML)
        <math xmlns="http://www.w3.org/1998/Math/MathML"><mn>0,7</mn></math>
      XML
      m.content.should include("0,7")
    end
  end

  describe "StemInlineElement produces SemanticMathElement" do
    it "math children are SemanticMathElement" do
      stem = Metanorma::Document::Components::Inline::StemInlineElement.from_xml(<<~XML)
        <stem xmlns="https://www.metanorma.org/ns/standoc" block="false" type="MathML">
          <math xmlns="http://www.w3.org/1998/Math/MathML"><mn>0.7</mn></math>
        </stem>
      XML
      Array(stem.math).first.should be_a(Metanorma::Document::Components::Inline::SemanticMathElement)
    end
  end

  describe "SemxElement produces RenderedMathElement" do
    it "math children are RenderedMathElement" do
      semx = Metanorma::Document::Components::Inline::SemxElement.from_xml(<<~XML)
        <semx xmlns="https://www.metanorma.org/ns/standoc" element="stem" source="s1">
          <math xmlns="http://www.w3.org/1998/Math/MathML"><mn>0,7</mn></math>
        </semx>
      XML
      Array(semx.math).first.should be_a(Metanorma::Document::Components::Inline::RenderedMathElement)
    end
  end

  describe "distinguishing semantic from rendered by type" do
    it "semantic math is SemanticMathElement" do
      stem = Metanorma::Document::Components::Inline::StemInlineElement.from_xml(<<~XML)
        <stem xmlns="https://www.metanorma.org/ns/standoc" type="MathML">
          <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math>
        </stem>
      XML
      math = Array(stem.math).first
      math.is_a?(Metanorma::Document::Components::Inline::SemanticMathElement).should be(true)
      math.is_a?(Metanorma::Document::Components::Inline::RenderedMathElement).should be(false)
    end

    it "rendered math is RenderedMathElement" do
      semx = Metanorma::Document::Components::Inline::SemxElement.from_xml(<<~XML)
        <semx xmlns="https://www.metanorma.org/ns/standoc" element="stem" source="s1">
          <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math>
        </semx>
      XML
      math = Array(semx.math).first
      math.is_a?(Metanorma::Document::Components::Inline::RenderedMathElement).should be(true)
      math.is_a?(Metanorma::Document::Components::Inline::SemanticMathElement).should be(false)
    end
  end
end
