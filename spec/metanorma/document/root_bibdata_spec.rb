# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Document::Root do
  let(:xml) do
    <<~XML
      <metanorma>
        <bibdata type="standard">
          <title language="en" type="main">OIML R 60</title>
          <docidentifier primary="true" type="ISO">OIML R 60</docidentifier>
        </bibdata>
      </metanorma>
    XML
  end

  it "parses the embedded document bibdata" do
    doc = described_class.from_xml(xml)

    expect(doc.bibdata).to be_a(
      Metanorma::BasicDocument::BibData::BibliographicItem,
    )
    expect(doc.bibdata.docidentifier.first.primary).to be_truthy
  end

  it "retains the docidentifier across a round-trip" do
    roundtrip = described_class.from_xml(xml).to_xml
    doc = Nokogiri::XML(roundtrip)

    expect(doc.at_xpath("//bibdata/docidentifier").text).to eq("OIML R 60")
  end
end
