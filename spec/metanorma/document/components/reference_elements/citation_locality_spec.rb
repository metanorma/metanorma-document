# frozen_string_literal: true

require_relative "../../../../spec_helper"

RSpec.describe "direct locality mapping on citation carriers" do
  it "maps direct locality children on eref" do
    xml = <<~XML
      <eref bibitemid="ISO712" citeas="ISO 712">
        <locality type="section"><referenceFrom>3.1</referenceFrom></locality>
      </eref>
    XML

    eref = Metanorma::Document::Components::Inline::ErefElement.from_xml(xml)

    expect(eref.bibitemid).to eq("ISO712")
    expect(eref.locality.size).to eq(1)
    expect(eref.locality.first.type).to eq("section")
    expect(eref.locality.first.reference_from).to eq("3.1")
  end

  it "maps direct locality children on the origin Citation carrier" do
    xml = <<~XML
      <citation bibitemid="ISO712" citeas="ISO 712" type="inline">
        <locality type="section"><referenceFrom>3.1</referenceFrom></locality>
        <locality type="table"><referenceFrom>2</referenceFrom></locality>
      </citation>
    XML

    citation = Metanorma::Document::Components::ReferenceElements::Citation.from_xml(xml)

    expect(citation.locality.size).to eq(2)
    expect(citation.locality.map(&:type)).to eq(%w[section table])
    expect(citation.locality.map(&:reference_from)).to eq(%w[3.1 2])
  end

  it "keeps localityStack mapping intact alongside direct localities" do
    xml = <<~XML
      <eref bibitemid="ISO712" citeas="ISO 712">
        <localityStack><locality type="clause"><referenceFrom>5</referenceFrom></locality></localityStack>
        <locality type="section"><referenceFrom>3.1</referenceFrom></locality>
      </eref>
    XML

    eref = Metanorma::Document::Components::Inline::ErefElement.from_xml(xml)

    expect(eref.locality_stack.size).to eq(1)
    expect(eref.locality.size).to eq(1)
    expect(eref.locality.first.reference_from).to eq("3.1")
  end
end
