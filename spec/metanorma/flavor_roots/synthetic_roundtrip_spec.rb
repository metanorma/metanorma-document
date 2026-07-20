# frozen_string_literal: true

require_relative "../../spec_helper"

# Synthetic round-trip coverage for the six flavors that have no public
# sample documents on mn-samples: bsi, gb, generic, jis, nist, plateau.
# Each flavor gets a "parses" and a "round-trips" example built from a
# minimal inline <metanorma> document exercising the flavor's
# distinguishing structures (see TODO.done/TODO.flavor-roots/).
RSpec.describe "Synthetic round-trips for flavors without sample documents" do
  def round_trip(root_class, xml)
    doc = root_class.from_xml(xml)
    output = doc.to_xml
    reparsed = root_class.from_xml(output)
    [doc, reparsed, output]
  end

  # --- BSI: <section-title> + commentary admonition with target ---

  describe "BSI" do
    let(:xml) do
      <<~XML
        <metanorma type="semantic" version="1.0">
          <bibdata type="standard"><title>BSI Doc</title></bibdata>
          <sections>
            <section-title id="_fst1" depth="2">Preamble</section-title>
            <clause id="_c1">
              <title>Scope</title>
              <admonition id="_ad1" type="commentary" target="_c1">
                <p>Commentary on scope</p>
              </admonition>
              <p>Text</p>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "parses the flavor root with its distinguishing features" do
      doc = Metanorma::BsiDocument::Root.from_xml(xml)
      fst = doc.sections.floating_section_title.first
      admonition = doc.sections.clause.first.admonitions.first
      expect(doc.sections).to be_a(Metanorma::BsiDocument::Sections::BsiSections)
      expect(fst.id).to eq("_fst1")
      expect(fst.depth).to eq(2)
      expect(fst.text).to eq(["Preamble"])
      expect(admonition.type).to eq("commentary")
      expect(admonition.target).to eq("_c1")
    end

    it "round-trips the flavor-specific structures" do
      _, reparsed, output = round_trip(Metanorma::BsiDocument::Root, xml)
      expect(output).to include("<section-title")
      expect(output).to include('depth="2"')
      expect(output).to include('type="commentary"')
      expect(output).to include('target="_c1"')
      expect(reparsed.sections.floating_section_title.length).to eq(1)
      expect(reparsed.sections.clause.first.admonitions.first.target)
        .to eq("_c1")
    end
  end

  # --- GB: <metanorma> root, pure ISO fallback (terms with boilerplate) ---

  describe "GB" do
    let(:xml) do
      <<~XML
        <metanorma type="semantic" version="1.0">
          <bibdata type="standard"><title>GB Doc</title></bibdata>
          <sections>
            <clause id="_c1"><title>Scope</title><p>Text</p></clause>
            <terms id="_t1">
              <title>Terms</title>
              <p>Boilerplate paragraph</p>
              <term id="_term1">
                <preferred><expression><name>test term</name></expression></preferred>
                <definition><p>A definition</p></definition>
              </term>
            </terms>
          </sections>
          <annex id="_a1" obligation="informative">
            <title>Annex</title><p>Annex text</p>
          </annex>
        </metanorma>
      XML
    end

    it "parses the flavor root through the ISO fallback" do
      doc = Metanorma::GbDocument::Root.from_xml(xml)
      register = Lutaml::Model::GlobalRegister.lookup(:gb_document)
      expect(register.fallback).to include(:iso_document)
      expect(doc.sections).to be_a(Metanorma::IsoDocument::Sections::IsoSections)
      expect(doc.annex.first)
        .to be_a(Metanorma::IsoDocument::Sections::IsoAnnexSection)
      expect(doc.sections.terms.p.length).to eq(1)
      expect(doc.sections.terms.term.length).to eq(1)
    end

    it "round-trips the flavor-specific structures" do
      _, reparsed, output = round_trip(Metanorma::GbDocument::Root, xml)
      expect(output).to include('<clause id="_c1"')
      expect(output).to include('<terms id="_t1"')
      expect(output).to include('<annex id="_a1"')
      expect(reparsed.sections.terms.term.length).to eq(1)
      expect(reparsed.annex.length).to eq(1)
    end
  end

  # --- Generic: sections collection + misc-container ---

  describe "Generic" do
    let(:xml) do
      <<~XML
        <metanorma type="semantic" version="1.0">
          <bibdata type="standard"><title>Generic Doc</title></bibdata>
          <sections>
            <clause id="_c1"><title>Part 1</title><p>Text</p></clause>
          </sections>
          <sections>
            <clause id="_c2"><title>Part 2</title><p>More text</p></clause>
          </sections>
          <misc-container semx-id="_mc1">
            <presentation-metadata><name>TOC Heading Levels</name><value>2</value></presentation-metadata>
          </misc-container>
        </metanorma>
      XML
    end

    it "parses the flavor root with its distinguishing features" do
      doc = Metanorma::GenericDocument::Root.from_xml(xml)
      metadata = doc.misccontainer.presentation_metadata.first
      expect(doc.sections.length).to eq(2)
      expect(doc.sections.last.clause.first.id).to eq("_c2")
      expect(doc.misccontainer.semx_id).to eq("_mc1")
      expect(metadata.name).to eq("TOC Heading Levels")
      expect(metadata.value).to eq("2")
    end

    it "round-trips the flavor-specific structures" do
      _, reparsed, output = round_trip(Metanorma::GenericDocument::Root, xml)
      expect(output).to include("<misc-container")
      expect(output).to include("<presentation-metadata>")
      expect(output).to include("<name>TOC Heading Levels</name>")
      expect(output).to include("<value>2</value>")
      expect(reparsed.sections.length).to eq(2)
      expect(reparsed.misccontainer.presentation_metadata.first.value)
        .to eq("2")
    end
  end

  # --- JIS: annex with commentary attribute ---

  describe "JIS" do
    let(:xml) do
      <<~XML
        <metanorma type="semantic" version="1.0">
          <bibdata type="standard"><title>JIS Doc</title></bibdata>
          <sections>
            <clause id="_c1"><title>Scope</title><p>Text</p></clause>
          </sections>
          <annex id="_a1" obligation="informative" commentary="true">
            <title>Commentary</title>
            <clause id="_ac1"><title>Notes</title><p>Commentary text</p></clause>
          </annex>
        </metanorma>
      XML
    end

    it "parses the flavor root with its distinguishing features" do
      doc = Metanorma::JisDocument::Root.from_xml(xml)
      expect(doc.annex.first)
        .to be_a(Metanorma::JisDocument::Sections::JisAnnexSection)
      expect(doc.annex.first.commentary).to be(true)
      expect(doc.annex.first.clause.length).to eq(1)
    end

    it "round-trips the flavor-specific structures" do
      _, reparsed, output = round_trip(Metanorma::JisDocument::Root, xml)
      expect(output).to include('commentary="true"')
      expect(reparsed.annex.first.commentary).to be(true)
      expect(reparsed.annex.first.clause.length).to eq(1)
    end
  end

  # --- NIST: NistPreface with errata clause and errata rows ---

  describe "NIST" do
    let(:xml) do
      <<~XML
        <metanorma type="semantic" version="1.0">
          <bibdata type="standard"><title>NIST Doc</title></bibdata>
          <preface>
            <errata_clause id="_ec">
              <title>Errata</title>
              <errata>
                <row>
                  <date>2024-01-01</date>
                  <type>typographical</type>
                  <change>Fixed typo</change>
                  <pages>5</pages>
                </row>
                <row>
                  <date>2024-06-15</date>
                  <type>technical</type>
                  <change>Corrected value</change>
                  <pages>12</pages>
                </row>
              </errata>
            </errata_clause>
          </preface>
          <sections>
            <clause id="_c1"><title>Scope</title><p>Text</p></clause>
          </sections>
        </metanorma>
      XML
    end

    it "parses the flavor root with its distinguishing features" do
      doc = Metanorma::NistDocument::Root.from_xml(xml)
      rows = doc.preface.errata_clause.first.errata.rows
      expect(doc.preface).to be_a(Metanorma::NistDocument::Sections::NistPreface)
      expect(rows.length).to eq(2)
      expect(rows.first.date).to eq("2024-01-01")
      expect(rows.first.type).to eq("typographical")
      expect(rows.first.change).to eq(["Fixed typo"])
      expect(rows.first.pages).to eq("5")
      expect(rows.last.type).to eq("technical")
    end

    it "round-trips the flavor-specific structures" do
      _, reparsed, output = round_trip(Metanorma::NistDocument::Root, xml)
      expect(output).to include("<errata_clause")
      expect(output).to include("<errata>")
      expect(output).to include("<date>2024-01-01</date>")
      expect(output).to include("<pages>12</pages>")
      expect(reparsed.preface.errata_clause.first.errata.rows.length).to eq(2)
    end
  end

  # --- Plateau: Plateau -> JIS -> ISO fallback chain ---

  describe "Plateau" do
    let(:xml) do
      <<~XML
        <metanorma type="semantic" version="1.0">
          <bibdata type="standard"><title>Plateau Doc</title></bibdata>
          <sections>
            <clause id="_c1"><title>Scope</title><p>Text</p></clause>
          </sections>
          <annex id="_a1" obligation="informative" commentary="true">
            <title>Commentary</title>
            <clause id="_ac1"><title>Notes</title><p>Text</p></clause>
          </annex>
        </metanorma>
      XML
    end

    it "parses the flavor root through the JIS fallback chain" do
      doc = Metanorma::PlateauDocument::Root.from_xml(xml)
      register = Lutaml::Model::GlobalRegister.lookup(:plateau_document)
      expect(register.fallback).to include(:jis_document)
      expect(doc.sections).to be_a(Metanorma::IsoDocument::Sections::IsoSections)
      expect(doc.annex.first)
        .to be_a(Metanorma::JisDocument::Sections::JisAnnexSection)
      expect(doc.annex.first.commentary).to be(true)
    end

    it "round-trips the flavor-specific structures" do
      _, reparsed, output = round_trip(Metanorma::PlateauDocument::Root, xml)
      expect(output).to include('commentary="true"')
      expect(output).to include('<clause id="_c1"')
      expect(reparsed.annex.first.commentary).to be(true)
      expect(reparsed.sections.clause.length).to eq(1)
    end
  end
end
