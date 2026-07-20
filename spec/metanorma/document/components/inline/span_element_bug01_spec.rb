# frozen_string_literal: true

require "spec_helper"
require "metanorma/document"

RSpec.describe "BUGS.sts 01: SpanElement preserves <stem> children" do
  def parse_span(xml)
    Metanorma::Document::Components::Inline::SpanElement.from_xml(xml)
  end

  def child_classes(element)
    children = []
    element.each_mixed_content do |node|
      children << (node.is_a?(String) ? "String" : node.class)
    end
    children
  end

  it "preserves a stem child inside span" do
    span = parse_span(<<~XML)
      <span xmlns="https://www.metanorma.org/ns/standoc">
        <stem block="false" type="MathML">
          <math xmlns="http://www.w3.org/1998/Math/MathML"><mn>5</mn></math>
        </stem>
        for load cells of class A;
      </span>
    XML
    children = child_classes(span)
    expect(children).to include(Metanorma::Document::Components::Inline::StemInlineElement)
  end

  it "preserves an em child inside span" do
    span = parse_span("<span xmlns='https://www.metanorma.org/ns/standoc'>text <em>emphatic</em> more</span>")
    children = child_classes(span)
    expect(children).to include(Metanorma::Document::Components::Inline::EmRawElement)
  end

  it "preserves a fn child inside span" do
    span = parse_span("<span xmlns='https://www.metanorma.org/ns/standoc'>see<fn reference='1' id='n1'>note</fn></span>")
    children = child_classes(span)
    expect(children).to include(Metanorma::Document::Components::Inline::FnElement)
  end

  it "preserves a link child inside span" do
    span = parse_span("<span xmlns='https://www.metanorma.org/ns/standoc'><link target='https://example.com'>docs</link></span>")
    children = child_classes(span)
    expect(children).to include(Metanorma::Document::Components::Inline::LinkElement)
  end

  it "preserves an xref child inside span" do
    span = parse_span("<span xmlns='https://www.metanorma.org/ns/standoc'>see <xref target='sec-1'>1</xref></span>")
    children = child_classes(span)
    expect(children).to include(Metanorma::Document::Components::Inline::XrefElement)
  end

  it "preserves a nested span child" do
    span = parse_span("<span xmlns='https://www.metanorma.org/ns/standoc'><span style='inner'>text</span></span>")
    children = child_classes(span)
    expect(children).to include(Metanorma::Document::Components::Inline::SpanElement)
  end

  it "preserves all children in document order" do
    span = parse_span(<<~XML)
      <span xmlns="https://www.metanorma.org/ns/standoc">
        <em>first</em>
        <strong>second</strong>
        <stem block="false" type="MathML">
          <math xmlns="http://www.w3.org/1998/Math/MathML"><mn>1</mn></math>
        </stem>
      </span>
    XML
    children = child_classes(span).reject { |c| c == "String" }
    expect(children).to eq([
                             Metanorma::Document::Components::Inline::EmRawElement,
                             Metanorma::Document::Components::Inline::StrongRawElement,
                             Metanorma::Document::Components::Inline::StemInlineElement,
                           ])
  end
end
