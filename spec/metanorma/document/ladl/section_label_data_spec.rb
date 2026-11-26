# frozen_string_literal: true

require "rspec"
require "nokogiri"
require_relative "../../../../lib/metanorma/document"

RSpec.describe "Section and subfigure presentation label data" do
  let(:sections) { Metanorma::Document::Components::Sections }
  let(:figures) { Metanorma::Document::Components::AncillaryBlocks }
  let(:data_xml) { '<fmt-ladl-label-data local="2" global="Clause 2" value="2" labeller="clause"/>' }

  before { Lutaml::Model::Config.xml_adapter_type = :nokogiri }

  it "persists label data on a basic section through XML roundtrip" do
    section = sections::BasicSection.from_xml(%(<basic-section id="c">#{data_xml}</basic-section>))
    again = sections::BasicSection.from_xml(section.to_xml)
    expect(%i[local global value labeller].map { |k| again.fmt_ladl_label_data.public_send(k) })
      .to eq(["2", "Clause 2", "2", "clause"])
  end

  it "inherits label data in hierarchical and references sections" do
    [sections::HierarchicalSection, sections::ReferencesSection].each do |klass|
      expect(klass.attributes).to include(:fmt_ladl_label_data)
    end
  end

  it "adds nothing to a section without label data" do
    section = sections::BasicSection.from_xml('<basic-section id="c"/>')
    expect(section.fmt_ladl_label_data).to be_nil
    expect(section.to_xml).not_to include("fmt-ladl-label-data")
  end

  it "persists label data on a subfigure" do
    fig = figures::Subfigure.from_xml(%(<figure id="sf">#{data_xml}</figure>))
    expect(figures::Subfigure.from_xml(fig.to_xml).fmt_ladl_label_data.global).to eq("Clause 2")
  end
end
