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
    locations.size.should eq(3)
    locations.map(&:target).should eq(%w[fig-4 sec-5.1.6 sec-5.1.7])
    locations.map(&:connective).should eq(%w[and and and])
  end

  it "preserves primary target attribute" do
    xml = '<xref xmlns="https://www.metanorma.org/ns/standoc" target="fig-4" id="x1"><location target="x" connective="and"/></xref>'
    xref = Metanorma::Document::Components::Inline::XrefElement.from_xml(xml)
    xref.target.should eq("fig-4")
    xref.id.should eq("x1")
  end

  it "exposes location as LocationElement instances" do
    xml = '<xref xmlns="https://www.metanorma.org/ns/standoc" target="fig-4"><location target="x" connective="and"/></xref>'
    xref = Metanorma::Document::Components::Inline::XrefElement.from_xml(xml)
    Array(xref.location).first.should be_a(Metanorma::Document::Components::Inline::LocationElement)
  end

  it "returns empty array when no locations present" do
    xml = '<xref xmlns="https://www.metanorma.org/ns/standoc" target="fig-4">only text</xref>'
    xref = Metanorma::Document::Components::Inline::XrefElement.from_xml(xml)
    Array(xref.location).should be_empty
  end

  describe Metanorma::Document::Components::Inline::LocationElement do
    it "parses target and connective attributes" do
      loc = described_class.from_xml(
        '<location xmlns="https://www.metanorma.org/ns/standoc" target="t1" connective="or"/>',
      )
      loc.target.should eq("t1")
      loc.connective.should eq("or")
    end

    it "round-trips through XML" do
      loc = described_class.new(
        target: "sec-1", connective: "and",
      )
      xml = loc.to_xml
      xml.should include("target=\"sec-1\"")
      xml.should include("connective=\"and\"")
    end
  end
end
