# frozen_string_literal: true

require "spec_helper"
require "metanorma/document"

RSpec.describe "BUGS.sts 05: SemanticContent filters fmt-* duplicates" do
  describe Metanorma::Document::Components::Inline::RenderedDisplay do
    it "is included in every fmt_* class" do
      fmt_classes = Metanorma::Document::Components::Inline.constants
        .map { |c| Metanorma::Document::Components::Inline.const_get(c) }
        .select { |c| c.is_a?(Class) && c.name.end_with?("Element") && c.name.include?("Fmt") }
      fmt_classes.each do |klass|
        expect(klass.include?(described_class)).to be(true),
                                                   "#{klass.name} should include RenderedDisplay"
      end
    end

    it "is NOT included in non-fmt classes" do
      expect(Metanorma::Document::Components::Inline::SpanElement.include?(
               described_class,
             )).to be(false)
    end
  end

  describe Metanorma::Document::Components::Inline::SemanticContent do
    def parse_p(xml)
      Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(xml)
    end

    it "yields only semantic children (fmt_* skipped)" do
      p = parse_p(<<~XML)
        <p xmlns="https://www.metanorma.org/ns/standoc">
          Hello
          <stem block="false" type="MathML" id="s1">
            <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math>
          </stem>
          <fmt-stem type="MathML">
            <semx element="stem" source="s1">
              <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math>
            </semx>
          </fmt-stem>
          world
        </p>
      XML

      yielded = []
      described_class.each(p) do |node|
        yielded << node
      end

      stem_classes = yielded.grep(Lutaml::Model::Serializable)
        .map(&:class)
      expect(stem_classes).to include(Metanorma::Document::Components::Inline::StemInlineElement)
      expect(stem_classes).not_to include(Metanorma::Document::Components::Inline::FmtStemElement)
    end

    it "returns an Enumerator when no block given" do
      p = parse_p("<p xmlns='https://www.metanorma.org/ns/standoc'>text</p>")
      enum = described_class.each(p)
      expect(enum).to be_a(Enumerator)
      expect(enum.to_a).to be_a(Array)
    end

    it "still yields text nodes" do
      p = parse_p("<p xmlns='https://www.metanorma.org/ns/standoc'>hello world</p>")
      strings = []
      described_class.each(p) do |n|
        strings << n if n.is_a?(String)
      end
      expect(strings.join).to include("hello world")
    end

    it "yields semantic concept but not fmt_concept" do
      p = parse_p(<<~XML)
        <p xmlns="https://www.metanorma.org/ns/standoc">
          <concept is-a="term" ref="t1"/>
          <fmt-concept>
            <semx element="concept" source="t1">term-text</semx>
          </fmt-concept>
        </p>
      XML

      yielded = []
      described_class.each(p) { |n| yielded << n }
      classes = yielded.grep(Lutaml::Model::Serializable).map(&:class)
      expect(classes).to include(Metanorma::Document::Components::Inline::ConceptElement)
      expect(classes).not_to include(Metanorma::Document::Components::Inline::FmtConceptElement)
    end
  end
end
