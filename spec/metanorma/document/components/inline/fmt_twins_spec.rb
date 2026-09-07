# frozen_string_literal: true

require "spec_helper"

# The fmt-* rendered twins (#63): presentation XML carries semantic +
# rendered siblings — the rendered side must parse as typed content
# and never duplicate plain text.
RSpec.describe "fmt presentation twins" do
  describe Metanorma::Document::Components::Inline::FmtErefElement do
    it "parses the full eref contract under its own root" do
      fmt = described_class.from_xml(
        '<fmt-eref type="inline" bibitemid="ISO7301" citeas="ISO 7301">' \
        "ISO 7301<localityStack><locality type=\"clause\">" \
        "<referenceFrom>3.1</referenceFrom></locality></localityStack>" \
        "</fmt-eref>",
      )

      expect(fmt.bibitemid).to eq("ISO7301")
      expect(fmt.citeas).to eq("ISO 7301")
      expect(fmt.locality_stack.first.locality.first.type).to eq("clause")
      expect(fmt.text).to eq(["ISO 7301"])
    end

    it "round-trips under the fmt-eref root" do
      xml = '<fmt-eref bibitemid="R1" citeas="R1">R1</fmt-eref>'
      expect(described_class.from_xml(xml).to_xml)
        .to be_xml_equivalent_to(xml)
    end

    it "is marked as rendered display (filtered from semantic walks)" do
      expect(described_class.ancestors)
        .to include(Metanorma::Document::Components::Inline::RenderedDisplay)
    end
  end

  describe Metanorma::Document::Components::Inline::FmtOriginElement do
    it "round-trips under the fmt-origin root" do
      xml = '<fmt-origin bibitemid="R1" citeas="R1">R1</fmt-origin>'
      expect(described_class.from_xml(xml).to_xml)
        .to be_xml_equivalent_to(xml)
    end
  end

  describe Metanorma::Document::Components::Inline::FmtSourceElement do
    it "parses the rendered attribution semx slice" do
      fmt = described_class.from_xml(
        '<fmt-source status="adapted"><semx element="source" source="_s1">' \
        "ISO 7301, adapted</semx></fmt-source>",
      )

      expect(fmt.status).to eq("adapted")
      expect(fmt.semx.first.element_attr).to eq("source")
      expect(fmt.semx.first.text).to eq(["ISO 7301, adapted"])
    end
  end

  describe Metanorma::Document::Components::Inline::FmtDateInlineElement do
    it "parses inside the semantic date element" do
      date = Metanorma::Document::Components::Inline::DateElement.from_xml(
        '<date value="2026-09-07" format="dd-MM-yyyy">' \
        "<fmt-date-inline>07-09-2026</fmt-date-inline></date>",
      )

      expect(date.value).to eq("2026-09-07")
      expect(date.fmt_date_inline.first.text).to eq(["07-09-2026"])
    end
  end

  describe Metanorma::Document::Components::Inline::SourcelocalityStackElement do
    it "parses mixed text content" do
      stack = described_class.from_xml("<sourcelocalityStack>clause 3.1</sourcelocalityStack>")
      expect(stack.text).to eq(["clause 3.1"])
    end
  end

  describe Metanorma::Document::Components::AncillaryBlocks::FmtFigureElement do
    it "parses the rendered figure container" do
      fmt = described_class.from_xml(
        '<fmt-figure id="_ff1"><name>Rendered</name>' \
        '<image id="_i1" src="a.png"/></fmt-figure>',
      )

      expect(fmt.id).to eq("_ff1")
      expect(fmt.name).not_to be_nil
      expect(fmt.image.id).to eq("_i1")
    end
  end

  describe Metanorma::Document::Components::Lists::FmtUlElement do
    it "parses the table rendering of a list" do
      fmt = described_class.from_xml(
        '<fmt-ul id="_fu1"><table id="_t1"><tbody><tr><td>a</td></tr>' \
        "</tbody></table></fmt-ul>",
      )

      expect(fmt.id).to eq("_fu1")
      expect(fmt.table.first.id).to eq("_t1")
    end
  end

  describe "list and figure parents carry their twins" do
    it "parses fmt-ul inside ul alongside list items" do
      ul = Metanorma::Document::Components::Lists::UnorderedList.from_xml(
        "<ul><li>item</li><fmt-ul><table id=\"_t1\"/></fmt-ul></ul>",
      )

      expect(ul.listitem.size).to eq(1)
      expect(ul.fmt_ul.table.first.id).to eq("_t1")
    end

    it "parses fmt-ol inside ol" do
      ol = Metanorma::Document::Components::Lists::OrderedList.from_xml(
        "<ol><li>one</li><fmt-ol><table id=\"_t2\"/></fmt-ol></ol>",
      )

      expect(ol.listitem.size).to eq(1)
      expect(ol.fmt_ol.table.first.id).to eq("_t2")
    end

    it "parses fmt-figure inside figure" do
      figure = Metanorma::Document::Components::AncillaryBlocks::FigureBlock.from_xml(
        '<figure id="_f1"><name>Original</name><fmt-figure id="_ff1"/></figure>',
      )

      expect(figure.name).not_to be_nil
      expect(figure.fmt_figure.first.id).to eq("_ff1")
    end

    it "parses fmt-source inside quote source" do
      source = Metanorma::Document::Components::ReferenceElements::SourceElement.from_xml(
        '<source status="authored"><origin bibitemid="R1" citeas="R1"/>' \
        '<fmt-source status="adapted">R1, adapted</fmt-source></source>',
      )

      expect(source.origin.citeas).to eq("R1")
      expect(source.fmt_source.first.status).to eq("adapted")
    end
  end

  describe "emf image payloads" do
    it "captures emf like svg (raw element, asset payload)" do
      image = Metanorma::Document::Components::IdElements::Image.from_xml(
        '<image id="_i1"><emf>binary-payload</emf></image>',
      )

      expect(image.inline_emf).to include("binary-payload")
    end
  end

  describe "plain text: semantic + rendered pair linearizes once" do
    it "extracts one citation for eref + fmt-eref siblings in a cell" do
      cell = Metanorma::Document::Components::Tables::TextTableCell.from_xml(
        "<td>see <eref bibitemid=\"ISO7301\" citeas=\"ISO 7301\"/>" \
        "<fmt-eref bibitemid=\"ISO7301\" citeas=\"ISO 7301\">ISO 7301" \
        "</fmt-eref></td>",
      )

      expect(Metanorma::Document::PlainText.call(cell))
        .to eq("see ISO 7301")
    end

    it "keeps the rendered citation when the semantic eref is absent" do
      cell = Metanorma::Document::Components::Tables::TextTableCell.from_xml(
        "<td>see <fmt-eref bibitemid=\"ISO7301\" citeas=\"ISO 7301\">" \
        "ISO 7301</fmt-eref></td>",
      )

      expect(Metanorma::Document::PlainText.call(cell))
        .to eq("see ISO 7301")
    end

    it "skips the re-rendered list form (items carry the content)" do
      ul = Metanorma::Document::Components::Lists::UnorderedList.from_xml(
        "<ul><li>alpha</li><li>beta</li><fmt-ul><table/></fmt-ul></ul>",
      )

      text = Metanorma::Document::PlainText.call(ul)
      expect(text).to include("alpha")
      expect(text).not_to include("alphaalpha")
    end
  end
end
