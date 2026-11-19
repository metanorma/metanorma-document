# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Document::Relaton::LogoElement do
  # LogoElement is a type-only model: it declares no element and is
  # embedded through Organization's `map_element "logo"` (collection).
  # lutaml-model rejects direct root-level serialization of type-only
  # models with TypeOnlyMappingError, so this spec drives the class
  # through its real parent.
  let(:organization_xml) do
    <<~XML
      <organization>
        <name abbrev="ISO">International Organization for Standardization</name>
        <logo type="image/svg+xml">#{logo_inner}</logo>
      </organization>
    XML
  end

  let(:logo_inner) do
    "<svg><path d=\"M0 0\"/></svg>"
  end

  def parse_logo
    Metanorma::Document::Relaton::Organization
      .from_xml(organization_xml).logo.first
  end

  it "parses the logo type attribute" do
    logo = parse_logo

    expect(logo.type).to eq("image/svg+xml")
  end

  it "keeps the raw inline SVG payload as markup-encoded content" do
    logo = parse_logo

    expect(logo.content).to include("<svg>")
    expect(logo.content).to include('<path d="M0 0"/>')
  end

  it "round-trips the raw payload without double-escaping" do
    organization = Metanorma::Document::Relaton::Organization
      .from_xml(organization_xml)

    xml = organization.to_xml

    expect(xml).to include('type="image/svg+xml"')
    expect(xml).to include('<path d="M0 0"/>')
    expect(xml).not_to include("&amp;lt;")
  end

  it "re-parses its own output to an equivalent logo" do
    organization = Metanorma::Document::Relaton::Organization
      .from_xml(organization_xml)
    reparsed = Metanorma::Document::Relaton::Organization
      .from_xml(organization.to_xml)

    expect(reparsed.logo.first.type).to eq("image/svg+xml")
    expect(reparsed.logo.first.content).to include('<path d="M0 0"/>')
  end

  it "rejects direct root-level parsing with TypeOnlyMappingError" do
    expect do
      described_class.from_xml('<logo type="png">bytes</logo>')
    end.to raise_error(Lutaml::Model::TypeOnlyMappingError)
  end
end
