# frozen_string_literal: true

require "spec_helper"

# metanorma-ietf#292: strike/underline/smallcap hand-picked their
# inline children, so anything outside the picked set (a cross-
# reference inside strikethrough) was ghosted at parse - recorded in
# element_order but unreachable
RSpec.describe "inline vocabulary on formatting elements" do
  it "maps a cross-reference inside strike" do
    xml = '<p>cut <strike>see <xref target="o">X1</xref></strike></p>'

    p = Metanorma::Document::Components::Paragraphs::ParagraphBlock
      .from_xml(xml)

    strike = p.strike.first
    expect(strike.xref.first.target).to eq("o")
    expect(strike.xref.first).to respond_to(:text)
  end

  it "maps a cross-reference inside underline" do
    xml = '<p>see <underline><xref target="o">X2</xref></underline></p>'

    p = Metanorma::Document::Components::Paragraphs::ParagraphBlock
      .from_xml(xml)

    expect(p.underline.first.xref.first.target).to eq("o")
  end

  it "maps a cross-reference inside smallcap" do
    xml = '<p><smallcap>see <xref target="o">X3</xref></smallcap></p>'

    p = Metanorma::Document::Components::Paragraphs::ParagraphBlock
      .from_xml(xml)

    expect(p.smallcap.first.xref.first.target).to eq("o")
  end
end
