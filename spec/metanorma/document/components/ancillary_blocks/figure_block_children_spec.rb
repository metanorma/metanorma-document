# frozen_string_literal: true

require_relative "../../../../spec_helper"

# metanorma-ietf#303: pseudocode figures carry their content as
# paragraphs and sourcecode; the FigureBlock model mapped neither, so
# the content was unreachable at parse and pseudocode figures rendered
# empty.
RSpec.describe "p and sourcecode mapping on FigureBlock" do
  it "maps figure paragraphs" do
    xml = <<~XML
      <figure class="pseudocode"><name>Label</name>
        <p>first line</p>
        <p>second line</p>
      </figure>
    XML

    figure = Metanorma::Document::Components::AncillaryBlocks::FigureBlock
      .from_xml(xml)

    expect(figure.figure_class).to eq("pseudocode")
    expect(figure.p.size).to eq(2)
    expect(figure.p.map { |para| Metanorma::Document::PlainText.call(para) })
      .to eq(["first line", "second line"])
  end

  it "maps figure sourcecode" do
    xml = <<~XML
      <figure class="pseudocode"><name>Label</name>
        <sourcecode>if x then y</sourcecode>
      </figure>
    XML

    figure = Metanorma::Document::Components::AncillaryBlocks::FigureBlock
      .from_xml(xml)

    expect(figure.sourcecode.size).to eq(1)
    expect(Metanorma::Document::PlainText.call(figure.sourcecode.first))
      .to include("if x then y")
  end
end
