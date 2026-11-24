# frozen_string_literal: true

require "spec_helper"

# metanorma-ietf#297: containers dropped their non-paragraph children
# because the models mapped none - admonition lists, note sourcecode
# and the example note were unreachable at parse
RSpec.describe "container children mappings" do
  it "maps lists inside admonitions" do
    xml = '<admonition type="caution"><p>c</p><ul><li>l</li></ul></admonition>'

    ad = Metanorma::Document::Components::MultiParagraph::AdmonitionBlock
      .from_xml(xml)

    expect(Array(ad.ul).size).to eq(1)
  end

  it "maps sourcecode inside notes" do
    xml = "<note><p>n</p><sourcecode>sc</sourcecode></note>"

    nb = Metanorma::Document::Components::Blocks::NoteBlock.from_xml(xml)

    expect(Array(nb.sourcecode).size).to eq(1)
  end

  it "maps notes inside examples" do
    xml = '<example id="e"><p>body</p><note id="n"><p>ex note</p></note></example>'

    ex = Metanorma::Document::Components::AncillaryBlocks::ExampleBlock
      .from_xml(xml)

    expect(Array(ex.notes).size).to eq(1)
  end
end
