# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

# IEC/ISO Coding Guidelines (NISO STS 1.2 ed. 2.1) conformance of the
# engine's output for four constructs the IEC 616 validation run flagged:
# normative-reference citations (10.1.6/10.1.7), informal tables (6.2.1),
# quotation sources (5.9) and definition-list terms given only by a formula.
# Real models throughout: a small presentation document through the
# facade, no stubs.
RSpec.describe "Metanorma::Document::Sts guideline conformance (IEC 616)" do
  let(:profile) do
    Metanorma::Document::Sts::Profile.new(
      name: :iec616_guideline_conformance,
      dtd_version: "1.0",
      reader_class: Metanorma::Iso::Document::Root,
    )
  end

  # Presentation document: one scope clause carrying a normative-reference
  # citation, a quote with a source, a formula-only definition term, a
  # numbered table and an unnumbered table; one normative references
  # section whose bibitem has no URN (as for a document under preparation).
  let(:input_xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation" flavor="iso">
        <bibdata type="standard">
          <title language="en" type="main">Guideline conformance doc</title>
          <docidentifier primary="true" type="ISO">ISO 3</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1" type="scope"><title>Scope</title>
            <p id="p1">Determine as in <xref target="ISO16634">ISO 16634, clause 9</xref>.</p>
            <quote id="q1"><p id="p2">Quoted text.</p><attribution><p>ISO 7301</p></attribution></quote>
            <dl id="d1"><dt><stem type="MathML" block="false"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>w</mi></math></stem></dt><dd><p id="p3">is the fraction.</p></dd></dl>
            <table id="t1"><tbody><tr><td>a</td><td>b</td></tr></tbody></table>
            <table id="t2" autonum="1"><tbody><tr><td>c</td></tr></tbody></table>
          </clause>
          <references id="norm" normative="true"><title>Normative references</title>
            <p id="p4">The following documents are referred to.</p>
            <bibitem id="ISO16634" type="standard"><title format="text/plain">Dumas</title><docidentifier type="ISO">ISO 16634</docidentifier><formattedref><em>Cereals</em></formattedref></bibitem>
          </references>
        </sections>
      </metanorma>
    XML
  end

  let(:sts) { Metanorma::Document::Sts.convert(input_xml, profile: profile) }
  let(:doc) { Nokogiri::XML(sts) }
  let(:scope) { doc.at_xpath("//body/sec[@sec-type='scope']") }

  describe "normative-reference citations (Guidelines 10.1.6, 10.1.7)" do
    it "codes a citation of a reference without a URN as <std>, not as a bibr xref" do
      expect(doc.xpath("//xref[@ref-type='bibr'][@rid='ISO16634']")).to be_empty

      citation = scope.at_xpath("p[@id='p1']/std")
      expect(citation).not_to be_nil
      expect(citation.at_xpath("std-ref").text).to eq("ISO 16634")
      # No URN exists for this reference, so none is invented for the citation.
      expect(citation.xpath("std-id")).to be_empty
    end
  end

  describe "informal tables (Guidelines 6.2.1, 6.2.2)" do
    it "codes an unnumbered table as a bare <table> inside <array>" do
      unnumbered = scope.xpath("array/table")
      expect(unnumbered.size).to eq(1)
      expect(unnumbered.first.at_xpath("tbody/tr/td").text).to eq("a")
    end

    it "keeps a numbered table as a <table-wrap> carrying its label" do
      wrap = scope.at_xpath("table-wrap[@id='t2']")
      expect(wrap).not_to be_nil
      expect(wrap.at_xpath("label").text).to eq("Table 1")
      expect(wrap.at_xpath("table/tbody/tr/td").text).to eq("c")
    end
  end

  describe "quotation source (Guidelines 5.9)" do
    let(:quote) { scope.at_xpath("disp-quote") }

    it "codes the source as <attrib specific-use=\"source\">, not <attribution>" do
      expect(quote.xpath("attribution")).to be_empty
      attrib = quote.at_xpath("attrib")
      expect(attrib).not_to be_nil
      expect(attrib["specific-use"]).to eq("source")
      expect(attrib.text).to eq("ISO 7301")
    end

    it "places the source after the quoted paragraphs, as the disp-quote model requires" do
      expect(quote.element_children.map(&:name)).to eq(%w[p attrib])
    end
  end

  describe "definition-list terms (undeclared xsi:nil)" do
    it "never emits xsi:nil for a term given only by a formula" do
      expect(sts).not_to include("xsi:nil")
    end

    it "carries the formula as the term's content" do
      term = scope.at_xpath("def-list/def-item/term")
      expect(term).not_to be_nil
      expect(term.children).not_to be_empty
    end
  end
end
