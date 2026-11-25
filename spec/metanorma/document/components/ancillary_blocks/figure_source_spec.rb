# frozen_string_literal: true

require "spec_helper"

# metanorma-ietf#296 item 3: the figure <source> citation element was
# unmapped at parse (only the @source XML attribute was), so figure
# attributions never reached the flavor transformers
RSpec.describe "source element mapping on FigureBlock" do
  it "maps <source> citations into sources" do
    xml = <<~XML
      <figure id="f1"><name>Fig</name><image src="m.png"/>
        <source type="bibliographic">
          <origin bibitemid="rfc1234" type="inline"/>
        </source>
      </figure>
    XML

    figure = Metanorma::Document::Components::AncillaryBlocks::FigureBlock
      .from_xml(xml)

    expect(figure.sources.length).to eq(1)
    src = figure.sources.first
    expect(src.type).to eq("bibliographic")
    expect(src.origin.bibitemid).to eq("rfc1234")
  end

  it "keeps @source as the attribute spelling" do
    xml = '<figure id="f1" source="RFC 1234"><image src="m.png"/></figure>'

    figure = Metanorma::Document::Components::AncillaryBlocks::FigureBlock
      .from_xml(xml)

    expect(figure.source).to eq("RFC 1234")
    expect(figure.sources).to be_empty
  end
end
