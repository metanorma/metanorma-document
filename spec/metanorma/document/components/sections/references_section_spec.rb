# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Document::Components::Sections::ReferencesSection do
  # Admonition children (e.g. an `[EDITOR]` editorial note placed after the
  # reference list) are part of the section content: without the mapping
  # they were dropped at model ingest and never reached the renderers
  # (metanorma-iso#1764).
  let(:references_xml) do
    <<~XML
      <references-section>
        <title>Normative references</title>
        <references id="ISO80000-2">
          <title>Quantities and units</title>
        </references>
        <admonition type="editorial">
          <fmt-name>EDITORIAL NOTE</fmt-name>
          <p>This editorial note follows the reference list.</p>
        </admonition>
      </references-section>
    XML
  end

  it "declares references and admonition attributes" do
    expect(described_class.attributes.key?(:references)).to be(true)
    expect(described_class.attributes.key?(:admonition)).to be(true)
  end

  it "parses bibliographic references" do
    section = described_class.from_xml(references_xml)

    expect(section.references.length).to eq(1)
    expect(section.references.first.id).to eq("ISO80000-2")
  end

  it "parses admonition children" do
    section = described_class.from_xml(references_xml)

    expect(section.admonition.length).to eq(1)
    admonition = section.admonition.first
    expect(admonition.type).to eq("editorial")
    expect(admonition.paragraphs.length).to eq(1)
    expect(admonition.paragraphs.first.text.join).to include(
      "This editorial note follows the reference list."
    )
  end
end
