# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

# Inline citation text reaching the emitter (issue #205): fmt-xref
# labels wrapped in <strong> were dropped at parse time (no vocabulary
# mapping), and semx-sliced <fmt-eref> citations were excluded from the
# semx display walk — both rendered as empty anchors or bare spaces.
RSpec.describe "inline citation rendering" do
  let(:renderer) { Metanorma::Html::StandardRenderer.new }

  describe "fmt-xref with strong-wrapped label content" do
    let(:fmt_xref) do
      Metanorma::Document::Components::Inline::FmtXrefElement.from_xml(
        '<fmt-xref target="cls-4.1"><strong><span class="citesec">' \
        '<semx element="autonum" source="cls-4">4</semx>' \
        '<span class="fmt-autonum-delim">.</span>' \
        '<semx element="autonum" source="cls-4.1">1</semx>' \
        "</span></strong></fmt-xref>",
      )
    end

    it "parses the strong wrapper as typed content" do
      expect(Array(fmt_xref.strong).size).to eq(1)
      strong = fmt_xref.strong.first
      expect(Array(strong.span).size).to eq(1)
      expect(Array(strong.span.first.semx).size).to eq(2)
    end

    it "renders the anchor with its label text" do
      html = renderer.render_inline_element(fmt_xref)
      expect(html).to include('href="#cls-4.1"')
      expect(html).to include("4")
      expect(html).to include("1</span></strong></a>")
    end
  end

  describe "semx-sliced fmt-eref citation" do
    let(:render_semx) do
      ->(xml) { renderer.render_mixed_inline(Metanorma::Document::Components::Inline::SemxElement.from_xml(xml)) }
    end

    it "renders the citation text carried by the slice" do
      html = render_semx.call(
        '<semx element="eref" source="_1">' \
        '<fmt-eref type="inline" bibitemid="pas55" citeas="PAS 55">' \
        "PAS 55</fmt-eref></semx>",
      )
      expect(html).to eq("PAS 55")
    end

    it "falls back to citeas when the slice carries no text" do
      html = renderer.render_inline_element(
        Metanorma::Document::Components::Inline::FmtErefElement.from_xml(
          '<fmt-eref bibitemid="r1" citeas="PAS 55"/>',
        ),
      )
      expect(html).to eq("PAS 55")
    end

    it "renders fmt-origin slices the same way" do
      html = renderer.render_inline_element(
        Metanorma::Document::Components::Inline::FmtOriginElement.from_xml(
          '<fmt-origin bibitemid="r1" citeas="ISO 7301"/>',
        ),
      )
      expect(html).to eq("ISO 7301")
    end
  end
end
