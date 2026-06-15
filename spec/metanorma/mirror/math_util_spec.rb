# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::MathUtil do
  describe ".strip_xml_decl" do
    it "removes a leading XML declaration" do
      input = %(<?xml version="1.0"?><math>...</math>)
      described_class.strip_xml_decl(input).should eq("<math>...</math>")
    end

    it "returns the string unchanged when there is no declaration" do
      input = "<math>...</math>"
      described_class.strip_xml_decl(input).should eq(input)
    end
  end

  describe ".mathml_from_math" do
    it "joins an array of math objects via to_xml" do
      a = Object.new
      b = Object.new
      def a.to_xml; "<mi>a</mi>"; end
      def b.to_xml; "<mi>b</mi>"; end
      described_class.mathml_from_math([a, b]).should eq("<mi>a</mi><mi>b</mi>")
    end

    it "calls to_xml on a single math object" do
      obj = Object.new
      def obj.to_xml; "<mrow/>"; end
      described_class.mathml_from_math(obj).should eq("<mrow/>")
    end

    it "strips the XML declaration" do
      obj = Object.new
      def obj.to_xml; %(<?xml version="1.0"?><math/>); end
      described_class.mathml_from_math(obj).should eq("<math/>")
    end
  end

  describe ".asciimath_from_stem and .text_from_stem" do
    let(:fake_serializable) do
      Class.new(Lutaml::Models::Serializable) do
        attribute :text, :string
      end
    rescue NameError
      Class.new do
        def is_a?(klass)
          klass == Lutaml::Model::Serializable ? true : super
        end
      end
    end

    it "returns nil for elements without asciimath" do
      element = Class.new do
        def self.attributes
          {}
        end
      end.new
      described_class.asciimath_from_stem(element).should be_nil
    end

    it "returns empty string from text_from_stem for element without content" do
      element = Class.new do
        def self.attributes
          {}
        end
      end.new
      described_class.text_from_stem(element).should eq("")
    end
  end
end
