# frozen_string_literal: true

require "spec_helper"
require "metanorma/document"

# Regression coverage for the 2026-07-19 text-loss investigation:
# model declarations that silently dropped content (see
# TODO.consolidated.md). All root causes were local, not upstream.
RSpec.describe "mixed-content text-loss regressions" do
  describe "ErefElement" do
    it "preserves inline children and trailing text" do
      xml = '<eref type="inline" bibitemid="Ripple2005" citeas="[14]" ' \
            'id="e1">Ripple <em>et al.</em> 2005</eref>'
      out = Metanorma::Document::Components::Inline::ErefElement
        .from_xml(xml).to_xml
      expect(out).to include("<em>et al.</em>")
      expect(out).to include("2005")
    end
  end

  describe "CommaElement / EnumCommaElement" do
    it "captures and re-emits the comma character" do
      comma = Metanorma::Document::Components::Inline::CommaElement
        .from_xml("<comma>,</comma>")
      expect(comma.text).to eq(",")
    end

    it "captures and re-emits the enum-comma character" do
      enum = Metanorma::Document::Components::Inline::EnumCommaElement
        .from_xml("<enum-comma>,</enum-comma>")
      expect(enum.text).to eq(",")
      expect(enum.to_xml).to include("<enum-comma>,</enum-comma>")
    end
  end

  describe "Sections loose paragraphs (ITU zzSTDTitle1)" do
    it "keeps <p> directly under <sections>" do
      sections = Metanorma::StandardDocument::Sections::Sections.from_xml(<<~XML)
        <sections xmlns="https://www.metanorma.org/ns/standoc"><p class="zzSTDTitle1" displayorder="8">Draft title</p></sections>
      XML
      expect(sections.to_xml).to include("zzSTDTitle1")
    end
  end

  describe "Form inputs (OIML application forms)" do
    it "preserves <input> inside paragraphs" do
      p_el = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(<<~XML)
        <p xmlns="https://www.metanorma.org/ns/standoc" id="p1">Application no.: <input type="text" id="i1"/></p>
      XML
      expect(p_el.to_xml).to include("<input")
    end

    it "preserves <input> inside table cells" do
      table = Metanorma::Document::Components::Tables::TableBlock.from_xml(<<~XML)
        <table xmlns="https://www.metanorma.org/ns/standoc"><tbody><tr><td>PASS: <input type="checkbox" id="c1" checked="true"/></td></tr></tbody></table>
      XML
      expect(table.to_xml).to include("<input")
    end
  end
end
