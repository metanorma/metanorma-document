# frozen_string_literal: true

require "spec_helper"
require "metanorma/document"

RSpec.describe "BUGS.sts 04: XrefElement captures <location> children" do
  it "preserves multiple location children" do
    xml = <<~XML
      <xref xmlns="https://www.metanorma.org/ns/standoc" target="fig-4" id="x1">
        <location target="fig-4" connective="and"/>
        <location target="sec-5.1.6" connective="and"/>
        <location target="sec-5.1.7" connective="and"/>
      </xref>
    XML
    xref = Metanorma::Document::Components::Inline::XrefElement.from_xml(xml)
    locations = Array(xref.location)
    expect(locations.size).to eq(3)
    expect(locations.map(&:target)).to eq(%w[fig-4 sec-5.1.6 sec-5.1.7])
    expect(locations.map(&:connective)).to eq(%w[and and and])
  end

  it "preserves primary target attribute" do
    xml = '<xref xmlns="https://www.metanorma.org/ns/standoc" target="fig-4" id="x1"><location target="x" connective="and"/></xref>'
    xref = Metanorma::Document::Components::Inline::XrefElement.from_xml(xml)
    expect(xref.target).to eq("fig-4")
    expect(xref.id).to eq("x1")
  end

  it "exposes location as LocationElement instances" do
    xml = '<xref xmlns="https://www.metanorma.org/ns/standoc" target="fig-4"><location target="x" connective="and"/></xref>'
    xref = Metanorma::Document::Components::Inline::XrefElement.from_xml(xml)
    expect(Array(xref.location).first).to be_a(Metanorma::Document::Components::Inline::LocationElement)
  end

  it "returns empty array when no locations present" do
    xml = '<xref xmlns="https://www.metanorma.org/ns/standoc" target="fig-4">only text</xref>'
    xref = Metanorma::Document::Components::Inline::XrefElement.from_xml(xml)
    expect(Array(xref.location)).to be_empty
  end

  describe Metanorma::Document::Components::Inline::LocationElement do
    it "parses target and connective attributes" do
      loc = described_class.from_xml(
        '<location xmlns="https://www.metanorma.org/ns/standoc" target="t1" connective="or"/>',
      )
      expect(loc.target).to eq("t1")
      expect(loc.connective).to eq("or")
    end

    it "round-trips through XML" do
      loc = described_class.new(
        target: "sec-1", connective: "and",
      )
      xml = loc.to_xml
      expect(xml).to include("target=\"sec-1\"")
      expect(xml).to include("connective=\"and\"")
    end
  end
end
