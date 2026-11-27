# frozen_string_literal: true

require "spec_helper"

# Content-only inline containers (sup/sub/monospace) accept string
# children only: a model child (e.g. a fmt-xref mirrored inside a sup)
# must be skipped, never stringified. Lutaml::Model::Serializable#to_s
# falls back to Object#to_s (#inspect), which would leak a
# non-deterministic object address into the published XML.
RSpec.describe "Metanorma::Document::Sts inline containers never stringify model children" do
  let(:reader) { Metanorma::Iso::Document::Root }

  let(:input_xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation" flavor="iso">
        <bibdata type="standard">
          <title language="en" type="main">Sup xref inspect regression</title>
          <docidentifier primary="true" type="ISO">ISO 3</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1" type="scope">
            <title>Scope</title>
            <p id="p1">Reference <sup><fmt-xref type="footnote" target="r1">[1]</fmt-xref></sup> and to their use.</p>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  let(:profile_name) do
    name = :"sup_inspect_#{object_id}"
    Metanorma::Document::Sts::Profiles.register(
      Metanorma::Document::Sts::Profile.new(
        name: name, dtd_version: "1.0", reader_class: reader,
      ),
    )
    name
  end

  it "emits no object-inspect output for sup-wrapped xrefs" do
    output = Metanorma::Document::Sts.convert(input_xml, profile: profile_name)

    sups = Nokogiri::XML(output).xpath("//sup")
    expect(sups).not_to be_empty
    sup_text = sups.map(&:text).join
    expect(sup_text).not_to include("#")
    expect(sup_text).not_to include("0x")
  ensure
    Metanorma::Document::Sts::Profiles.delete(profile_name)
  end

  it "converts deterministically across runs" do
    first = Metanorma::Document::Sts.convert(input_xml, profile: profile_name)
    second = Metanorma::Document::Sts.convert(input_xml, profile: profile_name)

    expect(first).to eq(second)
  ensure
    Metanorma::Document::Sts::Profiles.delete(profile_name)
  end
end
