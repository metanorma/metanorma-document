# frozen_string_literal: true

require "spec_helper"
require "metanorma/iso"

# TODO.impl/08: svgmap/imagemap arrive as section children once the
# standoc wiring lands — the projection must not drop their figures.
RSpec.describe "MKO image-map walk" do
  def project_document(body_xml)
    xml = <<~XML
      <iso-standard xmlns="https://www.metanorma.org/ns/iso" type="semantic" flavor="iso">
        <bibdata type="standard"><title>Test</title></bibdata>
        <sections><clause id="_c1" obligation="normative"><title>Schemas</title>
          #{body_xml}
        </clause></sections>
      </iso-standard>
    XML
    model = Metanorma::Iso::Document::Root.from_xml(xml)
    Metanorma::Mko::Project.call(model)
  end

  it "emits a figure unit for each svgmap-wrapped figure" do
    result = project_document(
      '<svgmap id="_s1"><figure id="_f1"><name>Architecture</name>' \
      '<image src="arch.svg"/></figure>' \
      '<target href="B"><xref target="clause-2"/></target></svgmap>',
    )

    figures = result.units.select { |u| u.type == "figure" }
    expect(figures.size).to eq(1)
    expect(figures.first.title).to eq("Architecture")
  end

  it "emits figure units for imagemap-wrapped figures with area geometry" do
    result = project_document(
      '<imagemap id="_m1"><figure id="_f1"><name>Regions</name>' \
      '<image src="map.png"/></figure>' \
      '<area type="rect"><xref target="c1"/><coords x="0" y="0"/></area>' \
      "</imagemap>",
    )

    figures = result.units.select { |u| u.type == "figure" }
    expect(figures.size).to eq(1)
    expect(figures.first.title).to eq("Regions")
    payload = figures.first.payload
    expect(payload).to be_a(Hash) # serializable TablePayload-shaped hash
    expect(payload["mirror"]).not_to be_nil
  end

  it "orders map figures among sibling blocks in document order" do
    result = project_document(
      "<p>Intro</p>" \
      '<svgmap id="_s1"><figure id="_f1"><image src="a.svg"/></figure></svgmap>' \
      '<figure id="_f2"><image src="b.png"/></figure>',
    )

    figures = result.units.select { |u| u.type == "figure" }
    expect(figures.size).to eq(2)
    ids = figures.map { |f| f.anchor || f.id }
    expect(ids).to include("_f1", "_f2")
  end
end
