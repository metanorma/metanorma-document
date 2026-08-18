# frozen_string_literal: true

require_relative "../../../../spec_helper"

RSpec.describe "passthrough mapping on paragraph and inline carriers" do
  it "maps passthrough with its formats attribute on paragraphs" do
    xml = <<~XML
      <p>See <passthrough formats="html">HTML-only content</passthrough> for details.</p>
    XML

    para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(xml)

    expect(para.passthrough.size).to eq(1)
    expect(para.passthrough.first.formats).to eq("html")
    expect(para.passthrough.first.content).to include("HTML-only")
  end

  it "maps passthrough on vocabulary-based inline carriers" do
    xml = <<~XML
      <span class="keep">before <passthrough formats="docx">inner</passthrough> after</span>
    XML

    span = Metanorma::Document::Components::Inline::SpanElement.from_xml(xml)

    expect(span.passthrough.size).to eq(1)
    expect(span.passthrough.first.formats).to eq("docx")
    expect(span.passthrough.first.content).to eq("inner")
  end

  it "maps multiple passthrough elements in order-preserving collections" do
    xml = <<~XML
      <p><passthrough formats="html">one</passthrough> text <passthrough formats="pdf,tex">two</passthrough></p>
    XML

    para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(xml)

    expect(para.passthrough.map(&:formats)).to eq(%w[html pdf,tex])
    expect(para.passthrough.map(&:content)).to eq(%w[one two])
  end
end
