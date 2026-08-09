# frozen_string_literal: true

require "spec_helper"

RSpec.describe "metanorma-document model extensions for validation", type: :model do
  describe "IsoPreface#foreword required" do
    it "flags missing foreword via Layer 1 validate" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <preface/>
        </metanorma>
      XML
      root = Metanorma::IsoDocument::Root.from_xml(xml)
      errors = root.preface.validate
      expect(errors).not_to be_empty
      expect(errors.any? { |e| e.is_a?(Lutaml::Model::RequiredAttributeMissingError) }).to be(true)
    end

    it "passes when foreword is present" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <preface><foreword><p>text</p></foreword></preface>
        </metanorma>
      XML
      root = Metanorma::IsoDocument::Root.from_xml(xml)
      expect(root.preface.validate).to be_empty
    end
  end

  describe "StandardReferencesSection nested children" do
    it "preserves nested references sections" do
      xml = <<~XML
        <references normative="true">
          <title>Norm Refs</title>
          <bibitem id="iso1">ISO 1</bibitem>
          <references normative="true">
            <title>Sub-section</title>
          </references>
        </references>
      XML
      refs = Metanorma::StandardDocument::Sections::StandardReferencesSection.from_xml(xml)
      expect(refs.subsections.size).to eq(1)
    end

    it "preserves nested clause children" do
      xml = <<~XML
        <references normative="true">
          <title>Norm Refs</title>
          <clause id="sub"><title>Sub-clause</title></clause>
        </references>
      XML
      refs = Metanorma::StandardDocument::Sections::StandardReferencesSection.from_xml(xml)
      expect(refs.clauses.size).to eq(1)
    end
  end

  describe "SubElement recursive nesting" do
    it "preserves nested sub elements" do
      xml = "<sub>x<sub>y</sub></sub>"
      sub = Metanorma::Document::Components::Inline::SubElement.from_xml(xml)
      expect(sub.sub.size).to eq(1)
      expect(sub.sub.first.content).to eq("y")
    end
  end
end
