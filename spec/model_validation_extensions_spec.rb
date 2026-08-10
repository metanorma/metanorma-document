# frozen_string_literal: true

require "spec_helper"

RSpec.describe "metanorma-document model extensions for validation", type: :model do
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
