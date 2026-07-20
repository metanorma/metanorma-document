# frozen_string_literal: true

require_relative "../../spec_helper"

# Load all flavor modules before referencing their constants in describe blocks
require "metanorma/iso_document"
require "metanorma/iec_document"
require "metanorma/oiml_document"
require "metanorma/bsi_document"
require "metanorma/jis_document"
require "metanorma/gb_document"
require "metanorma/plateau_document"
require "metanorma/ogc_document"
require "metanorma/cc_document"
require "metanorma/csa_document"
require "metanorma/ribose_document"
require "metanorma/iho_document"
require "metanorma/bipm_document"
require "metanorma/itu_document"
require "metanorma/ieee_document"
require "metanorma/ietf_document"
require "metanorma/nist_document"
require "metanorma/generic_document"
require "metanorma/un_document"
require "metanorma/m3d_document"

RSpec.describe "Flavor Root classes" do
  def resolve_class(name)
    name.split("::").reduce(Object) { |o, c| o.const_get(c) }
  end

  # ============================================================
  # ISO-family flavors — use IsoDocument sections
  # ============================================================

  describe "ISO-family flavors" do
    {
      iso: "Metanorma::IsoDocument::Root",
      iec: "Metanorma::IecDocument::Root",
      oiml: "Metanorma::OimlDocument::Root",
      gb: "Metanorma::GbDocument::Root",
      csa: "Metanorma::CsaDocument::Root",
    }.each do |flavor, class_name|
      describe flavor.upcase.to_s do
        subject { resolve_class(class_name) }

        before(:all) { require "metanorma/#{flavor}_document" }

        it "uses IsoDocument preface" do
          expect(subject.attributes[:preface].type).to eq(
            Metanorma::IsoDocument::Sections::IsoPreface,
          )
        end

        it "uses IsoDocument sections" do
          expect(subject.attributes[:sections].type).to eq(
            Metanorma::IsoDocument::Sections::IsoSections,
          )
        end

        it "uses IsoDocument annex" do
          expect(subject.attributes[:annex].type).to eq(
            Metanorma::IsoDocument::Sections::IsoAnnexSection,
          )
        end
      end
    end
  end

  # ============================================================
  # BSI — ISO-family with custom sections/clause/annex
  # ============================================================

  describe "BSI" do
    subject { resolve_class("Metanorma::BsiDocument::Root") }

    it "uses IsoDocument preface" do
      expect(subject.attributes[:preface].type).to eq(
        Metanorma::IsoDocument::Sections::IsoPreface,
      )
    end

    it "uses BsiSections" do
      expect(subject.attributes[:sections].type).to eq(
        Metanorma::BsiDocument::Sections::BsiSections,
      )
    end

    it "uses BsiAnnexSection" do
      expect(subject.attributes[:annex].type).to eq(
        Metanorma::BsiDocument::Sections::BsiAnnexSection,
      )
    end
  end

  describe Metanorma::BsiDocument::Sections::BsiSections do
    it "inherits from IsoSections" do
      expect(described_class.superclass).to eq(
        Metanorma::IsoDocument::Sections::IsoSections,
      )
    end

    it "has floating_section_title attribute" do
      expect(described_class.attributes.keys).to include(:floating_section_title)
    end
  end

  describe Metanorma::BsiDocument::Sections::BsiClauseSection do
    it "inherits from IsoClauseSection" do
      expect(described_class.superclass).to eq(
        Metanorma::IsoDocument::Sections::IsoClauseSection,
      )
    end

    it "has floating_section_title attribute" do
      expect(described_class.attributes.keys).to include(:floating_section_title)
    end
  end

  describe Metanorma::BsiDocument::Sections::BsiAnnexSection do
    it "inherits from IsoAnnexSection" do
      expect(described_class.superclass).to eq(
        Metanorma::IsoDocument::Sections::IsoAnnexSection,
      )
    end

    it "has floating_section_title attribute" do
      expect(described_class.attributes.keys).to include(:floating_section_title)
    end

    it "inherits unnumbered through IsoAnnexSection → SD::AnnexSection chain" do
      expect(described_class.attributes.keys).to include(:unnumbered, :toc,
                                                         :floating_title)
    end
  end

  describe Metanorma::StandardDocument::Sections::FloatingSectionTitle do
    it "parses section-title with id and depth" do
      xml = '<section-title id="_fst1" depth="2">Section Title Text</section-title>'
      fst = described_class.from_xml(xml)
      expect(fst.id).to eq("_fst1")
      expect(fst.depth).to eq(2)
    end
  end

  # ============================================================
  # JIS — ISO-family with commentary annex
  # ============================================================

  describe "JIS" do
    subject { resolve_class("Metanorma::JisDocument::Root") }

    it "uses IsoDocument preface" do
      expect(subject.attributes[:preface].type).to eq(
        Metanorma::IsoDocument::Sections::IsoPreface,
      )
    end

    it "uses IsoDocument sections" do
      expect(subject.attributes[:sections].type).to eq(
        Metanorma::IsoDocument::Sections::IsoSections,
      )
    end

    it "uses JisAnnexSection" do
      expect(subject.attributes[:annex].type).to eq(
        Metanorma::JisDocument::Sections::JisAnnexSection,
      )
    end
  end

  describe Metanorma::JisDocument::Sections::JisAnnexSection do
    it "inherits from IsoAnnexSection" do
      expect(described_class.superclass).to eq(
        Metanorma::IsoDocument::Sections::IsoAnnexSection,
      )
    end

    it "has commentary attribute" do
      expect(described_class.attributes.keys).to include(:commentary)
    end

    it "inherits unnumbered through IsoAnnexSection → SD::AnnexSection chain" do
      expect(described_class.attributes.keys).to include(:unnumbered, :toc,
                                                         :floating_title)
    end

    it "parses annex with commentary attribute" do
      xml = <<~XML
        <annex id="_a1" obligation="informative" commentary="true">
          <title>Commentary</title>
          <clause id="_c1"><title>Note</title><p>Text</p></clause>
        </annex>
      XML
      annex = described_class.from_xml(xml)
      expect(annex.commentary).to be(true)
      expect(annex.clause.length).to eq(1)
    end
  end

  # ============================================================
  # IsoAnnexSection inheritance chain
  # ============================================================

  describe Metanorma::IsoDocument::Sections::IsoAnnexSection do
    it "inherits from StandardDocument::AnnexSection" do
      expect(described_class.superclass).to eq(
        Metanorma::StandardDocument::Sections::AnnexSection,
      )
    end

    it "inherits unnumbered from StandardDocument::AnnexSection" do
      expect(described_class.attributes.keys).to include(:unnumbered)
    end

    it "inherits toc from StandardDocument::AnnexSection" do
      expect(described_class.attributes.keys).to include(:toc)
    end

    it "inherits floating_title from StandardDocument::AnnexSection" do
      expect(described_class.attributes.keys).to include(:floating_title)
    end

    it "inherits block attributes from BlockAttributes" do
      attrs = described_class.attributes.keys
      expect(attrs).to include(:paragraphs, :tables, :figures, :notes)
    end

    it "overrides clause to IsoClauseSection" do
      expect(described_class.attributes[:clause].type).to eq(
        Metanorma::IsoDocument::Sections::IsoClauseSection,
      )
    end

    it "overrides terms to IsoTermsSection" do
      expect(described_class.attributes[:terms].type).to eq(
        Metanorma::IsoDocument::Sections::IsoTermsSection,
      )
    end

    it "parses annex with blocks and subsections" do
      xml = <<~XML
        <annex id="_a1" obligation="informative" unnumbered="true">
          <title>Appendix</title>
          <p>Block text</p>
          <clause id="_c1"><title>Sub</title><p>Sub text</p></clause>
          <terms id="_t1"><title>Terms</title></terms>
        </annex>
      XML
      annex = described_class.from_xml(xml)
      expect(annex.unnumbered).to be(true)
      expect(annex.paragraphs.length).to eq(1)
      expect(annex.clause.length).to eq(1)
      expect(annex.terms.length).to eq(1)
      expect(annex.clause.first).to be_a(
        Metanorma::IsoDocument::Sections::IsoClauseSection,
      )
    end
  end

  # ============================================================
  # Plateau — JIS-family with JisAnnexSection + extended TableBlock
  # ============================================================

  describe "Plateau" do
    subject { resolve_class("Metanorma::PlateauDocument::Root") }

    it "uses IsoDocument preface" do
      expect(subject.attributes[:preface].type).to eq(
        Metanorma::IsoDocument::Sections::IsoPreface,
      )
    end

    it "uses IsoDocument sections" do
      expect(subject.attributes[:sections].type).to eq(
        Metanorma::IsoDocument::Sections::IsoSections,
      )
    end

    it "uses JisAnnexSection" do
      expect(subject.attributes[:annex].type).to eq(
        Metanorma::JisDocument::Sections::JisAnnexSection,
      )
    end
  end

  describe "TableBlock extended attributes" do
    let(:table_class) { Metanorma::Document::Components::Tables::TableBlock }

    it "has example attribute" do
      expect(table_class.attributes.keys).to include(:example)
    end

    it "has sourcecode attribute" do
      expect(table_class.attributes.keys).to include(:sourcecode)
    end

    it "parses table with example and sourcecode" do
      xml = <<~XML
        <table id="_t1">
          <thead><tr><th>Header</th></tr></thead>
          <tbody><tr><td>Cell</td></tr></tbody>
          <example id="_ex1"><p>Example text</p></example>
          <sourcecode id="_sc1"><p>Code here</p></sourcecode>
        </table>
      XML

      table = table_class.from_xml(xml)
      expect(table.id).to eq("_t1")
      expect(table.example.length).to eq(1)
      expect(table.sourcecode.length).to eq(1)
    end

    it "has align attribute" do
      expect(table_class.attributes.keys).to include(:align)
    end

    it "parses table with align" do
      xml = '<table id="_t1" align="center"><tbody><tr><td>X</td></tr></tbody></table>'
      table = table_class.from_xml(xml)
      expect(table.align).to eq("center")
    end
  end

  # ============================================================
  # Block-level attribute extensions (IETF/BIPM TODO items)
  # ============================================================

  describe "Block-level attribute extensions" do
    describe Metanorma::Document::Components::Paragraphs::ParagraphBlock do
      it "has keep_with_previous attribute" do
        expect(described_class.attributes.keys).to include(:keep_with_previous)
      end

      it "has indent attribute" do
        expect(described_class.attributes.keys).to include(:indent)
      end

      it "parses paragraph with keep-with-previous and indent" do
        xml = '<p id="_p1" keep-with-previous="true" indent="3">Text</p>'
        para = described_class.from_xml(xml)
        expect(para.keep_with_previous).to be(true)
        expect(para.indent).to eq("3")
      end
    end

    describe Metanorma::Document::Components::Lists::UnorderedList do
      it "has nobullet attribute" do
        expect(described_class.attributes.keys).to include(:nobullet)
      end

      it "has spacing attribute" do
        expect(described_class.attributes.keys).to include(:spacing)
      end

      it "has indent attribute" do
        expect(described_class.attributes.keys).to include(:indent)
      end

      it "has bare attribute" do
        expect(described_class.attributes.keys).to include(:bare)
      end

      it "parses ul with IETF attributes" do
        xml = '<ul id="_ul1" nobullet="true" spacing="compact" indent="2" bare="true"><li><p>Item</p></li></ul>'
        ul = described_class.from_xml(xml)
        expect(ul.nobullet).to be(true)
        expect(ul.spacing).to eq("compact")
        expect(ul.indent).to eq("2")
        expect(ul.bare).to be(true)
      end

      it "round-trips ul with IETF attributes" do
        xml = '<ul id="_ul1" nobullet="true" spacing="compact"><li><p>Item</p></li></ul>'
        ul = described_class.from_xml(xml)
        expect(ul.to_xml).to include('nobullet="true"')
        expect(ul.to_xml).to include('spacing="compact"')
      end
    end

    describe Metanorma::Document::Components::Lists::OrderedList do
      it "has group attribute" do
        expect(described_class.attributes.keys).to include(:group)
      end

      it "has spacing attribute" do
        expect(described_class.attributes.keys).to include(:spacing)
      end

      it "has indent attribute" do
        expect(described_class.attributes.keys).to include(:indent)
      end

      it "parses ol with IETF attributes" do
        xml = '<ol id="_ol1" type="arabic" group="A" spacing="normal" indent="4"><li><p>Item</p></li></ol>'
        ol = described_class.from_xml(xml)
        expect(ol.group).to eq("A")
        expect(ol.spacing).to eq("normal")
        expect(ol.indent).to eq("4")
      end
    end

    describe Metanorma::Document::Components::Lists::DefinitionList do
      it "has newline attribute" do
        expect(described_class.attributes.keys).to include(:newline)
      end

      it "has indent attribute" do
        expect(described_class.attributes.keys).to include(:indent)
      end

      it "has spacing attribute" do
        expect(described_class.attributes.keys).to include(:spacing)
      end

      it "parses dl with IETF attributes" do
        xml = <<~XML
          <dl id="_dl1" newline="true" indent="2" spacing="normal">
            <dt>Term</dt>
            <dd><p>Definition</p></dd>
          </dl>
        XML
        dl = described_class.from_xml(xml)
        expect(dl.newline).to eq("true")
        expect(dl.indent).to eq("2")
        expect(dl.spacing).to eq("normal")
      end
    end

    describe Metanorma::Document::Components::Inline::XrefElement do
      it "has pagenumber attribute" do
        expect(described_class.attributes.keys).to include(:pagenumber)
      end

      it "has nosee attribute" do
        expect(described_class.attributes.keys).to include(:nosee)
      end

      it "has nopage attribute" do
        expect(described_class.attributes.keys).to include(:nopage)
      end

      it "has alt attribute" do
        expect(described_class.attributes.keys).to include(:alt)
      end

      it "parses xref with BIPM/IETF attributes" do
        xml = '<xref target="_s1" pagenumber="true" nosee="true" nopage="false" alt="Section 1"/>'
        xref = described_class.from_xml(xml)
        expect(xref.pagenumber).to eq("true")
        expect(xref.nosee).to eq("true")
        expect(xref.nopage).to eq("false")
        expect(xref.alt).to eq("Section 1")
      end

      it "round-trips xref with extended attributes" do
        xml = '<xref target="_s1" pagenumber="true" alt="Alt text"/>'
        xref = described_class.from_xml(xml)
        expect(xref.to_xml).to include('pagenumber="true"')
        expect(xref.to_xml).to include('alt="Alt text"')
      end
    end

    describe Metanorma::Document::Components::AncillaryBlocks::FigureBlock do
      it "has align attribute" do
        expect(described_class.attributes.keys).to include(:align)
      end

      it "parses figure with align" do
        xml = '<figure id="_f1" align="center"><image src="test.png"/></figure>'
        figure = described_class.from_xml(xml)
        expect(figure.align).to eq("center")
      end
    end

    describe Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock do
      it "has alt attribute" do
        expect(described_class.attributes.keys).to include(:alt)
      end

      it "parses sourcecode with alt" do
        xml = '<sourcecode id="_sc1" alt="Python example" lang="python">print("hello")</sourcecode>'
        sc = described_class.from_xml(xml)
        expect(sc.alt).to eq("Python example")
      end
    end

    describe Metanorma::Document::Components::IdElements::Image do
      it "has align attribute" do
        expect(described_class.attributes.keys).to include(:align)
      end

      it "parses image with align" do
        xml = '<image src="fig.png" align="right"/>'
        img = described_class.from_xml(xml)
        expect(img.align).to eq("right")
      end
    end

    describe Metanorma::Document::Components::MultiParagraph::ReviewBlock do
      it "has display attribute" do
        expect(described_class.attributes.keys).to include(:display)
      end

      it "parses review with display" do
        xml = '<review reviewer="Editor" display="true"><p>Comment text</p></review>'
        review = described_class.from_xml(xml)
        expect(review.display).to eq("true")
      end
    end
  end

  # ============================================================
  # Isodoc-family flavors — use StandardDocument sections
  # ============================================================

  describe "Isodoc-family flavors with StandardDocument sections" do
    {
      ogc: "Metanorma::OgcDocument::Root",
      cc: "Metanorma::CcDocument::Root",
      ribose: "Metanorma::RiboseDocument::Root",
      iho: "Metanorma::IhoDocument::Root",
      bipm: "Metanorma::BipmDocument::Root",
      itu: "Metanorma::ItuDocument::Root",
      m3d: "Metanorma::M3dDocument::Root",
    }.each do |flavor, class_name|
      describe flavor.upcase.to_s do
        subject { resolve_class(class_name) }

        before(:all) { require "metanorma/#{flavor}_document" }

        it "uses StandardDocument preface" do
          expect(subject.attributes[:preface].type).to eq(
            Metanorma::StandardDocument::Sections::Preface,
          )
        end

        it "uses StandardDocument sections" do
          expect(subject.attributes[:sections].type).to eq(
            Metanorma::StandardDocument::Sections::Sections,
          )
        end

        it "uses StandardDocument annex" do
          expect(subject.attributes[:annex].type).to eq(
            Metanorma::StandardDocument::Sections::AnnexSection,
          )
        end
      end
    end
  end

  # ============================================================
  # IEEE — custom IeeeSections
  # ============================================================

  describe "IEEE" do
    subject { resolve_class("Metanorma::IeeeDocument::Root") }

    before(:all) { require "metanorma/ieee_document" }

    it "uses StandardDocument preface" do
      expect(subject.attributes[:preface].type).to eq(
        Metanorma::StandardDocument::Sections::Preface,
      )
    end

    it "uses IeeeSections" do
      expect(subject.attributes[:sections].type).to eq(
        Metanorma::IeeeDocument::Sections::IeeeSections,
      )
    end

    it "uses StandardDocument annex" do
      expect(subject.attributes[:annex].type).to eq(
        Metanorma::StandardDocument::Sections::AnnexSection,
      )
    end
  end

  describe Metanorma::IeeeDocument::Sections::IeeeSections do
    it "inherits from StandardDocument Sections" do
      expect(described_class.superclass).to eq(
        Metanorma::StandardDocument::Sections::Sections,
      )
    end

    it "has a note attribute" do
      expect(described_class.attributes.keys).to include(:note)
    end

    it "parses sections with a leading note" do
      xml = <<~XML
        <sections>
          <note id="_n1"><p>Document-level note</p></note>
          <clause id="_c1"><title>Scope</title><p>Text</p></clause>
        </sections>
      XML

      sections = described_class.from_xml(xml)
      expect(sections.note).not_to be_nil
      expect(sections.clause.length).to eq(1)
    end
  end

  # ============================================================
  # IETF — custom IetfSections, IetfClauseSection, IetfAnnexSection
  # ============================================================

  describe "IETF" do
    subject { resolve_class("Metanorma::IetfDocument::Root") }

    before(:all) { require "metanorma/ietf_document" }

    it "uses StandardDocument preface" do
      expect(subject.attributes[:preface].type).to eq(
        Metanorma::StandardDocument::Sections::Preface,
      )
    end

    it "uses IetfSections" do
      expect(subject.attributes[:sections].type).to eq(
        Metanorma::IetfDocument::Sections::IetfSections,
      )
    end

    it "uses IetfAnnexSection" do
      expect(subject.attributes[:annex].type).to eq(
        Metanorma::IetfDocument::Sections::IetfAnnexSection,
      )
    end
  end

  describe Metanorma::IetfDocument::Sections::IetfContentSection do
    it "inherits from StandardDocument ContentSection" do
      expect(described_class.superclass).to eq(
        Metanorma::StandardDocument::Sections::ContentSection,
      )
    end

    it "has numbered attribute" do
      expect(described_class.attributes.keys).to include(:numbered)
    end

    it "has remove_in_rfc attribute" do
      expect(described_class.attributes.keys).to include(:remove_in_rfc)
    end

    it "parses preface clause with IETF-specific attributes" do
      xml = <<~XML
        <clause id="_abs" numbered="true" removeInRFC="false">
          <title>Abstract</title>
          <p>Some abstract text</p>
          <clause id="_sub" numbered="false"><title>Sub</title><p>Detail</p></clause>
        </clause>
      XML

      content = described_class.from_xml(xml)
      expect(content.numbered).to eq("true")
      expect(content.remove_in_rfc).to be(false)
      expect(content.subsection.length).to eq(1)
      expect(content.subsection.first).to be_a(described_class)
    end
  end

  describe Metanorma::IetfDocument::Sections::IetfSections do
    it "inherits from StandardDocument Sections" do
      expect(described_class.superclass).to eq(
        Metanorma::StandardDocument::Sections::Sections,
      )
    end

    it "has bibitem attribute" do
      expect(described_class.attributes.keys).to include(:bibitem)
    end
  end

  describe Metanorma::IetfDocument::Sections::IetfClauseSection do
    it "inherits from StandardDocument ClauseSection" do
      expect(described_class.superclass).to eq(
        Metanorma::StandardDocument::Sections::ClauseSection,
      )
    end

    it "has numbered attribute" do
      expect(described_class.attributes.keys).to include(:numbered)
    end

    it "has remove_in_rfc attribute" do
      expect(described_class.attributes.keys).to include(:remove_in_rfc)
    end

    it "parses clause with IETF-specific attributes" do
      xml = <<~XML
        <clause id="_c1" numbered="true" removeInRFC="true" toc="default">
          <title>Introduction</title>
          <p>Some text</p>
          <clause id="_c2" numbered="false"><title>Details</title><p>More</p></clause>
        </clause>
      XML

      clause = described_class.from_xml(xml)
      expect(clause.numbered).to eq("true")
      expect(clause.remove_in_rfc).to be(true)
      expect(clause.toc).to eq("default")
      expect(clause.clause.length).to eq(1)
      expect(clause.clause.first).to be_a(described_class)
    end
  end

  describe Metanorma::IetfDocument::Sections::IetfAnnexSection do
    it "inherits from StandardDocument AnnexSection" do
      expect(described_class.superclass).to eq(
        Metanorma::StandardDocument::Sections::AnnexSection,
      )
    end

    it "has numbered attribute" do
      expect(described_class.attributes.keys).to include(:numbered)
    end

    it "has remove_in_rfc attribute" do
      expect(described_class.attributes.keys).to include(:remove_in_rfc)
    end

    it "parses annex with IETF-specific attributes" do
      xml = <<~XML
        <annex id="_a1" obligation="informative" numbered="true" removeInRFC="false">
          <title>Appendix</title>
          <p>Text</p>
          <clause id="_c1"><title>Sub</title><p>Detail</p></clause>
        </annex>
      XML

      annex = described_class.from_xml(xml)
      expect(annex.numbered).to eq("true")
      expect(annex.remove_in_rfc).to be(false)
      expect(annex.clause.length).to eq(1)
      expect(annex.clause.first).to be_a(
        Metanorma::IetfDocument::Sections::IetfClauseSection,
      )
    end
  end

  # ============================================================
  # NIST — custom NistPreface with errata
  # ============================================================

  describe "NIST" do
    subject { resolve_class("Metanorma::NistDocument::Root") }

    before(:all) { require "metanorma/nist_document" }

    it "uses NistPreface" do
      expect(subject.attributes[:preface].type).to eq(
        Metanorma::NistDocument::Sections::NistPreface,
      )
    end

    it "uses StandardDocument sections" do
      expect(subject.attributes[:sections].type).to eq(
        Metanorma::StandardDocument::Sections::Sections,
      )
    end
  end

  describe Metanorma::NistDocument::Sections::NistPreface do
    it "inherits from StandardDocument Preface" do
      expect(described_class.superclass).to eq(
        Metanorma::StandardDocument::Sections::Preface,
      )
    end

    it "has errata_clause attribute" do
      expect(described_class.attributes.keys).to include(:errata_clause)
    end

    it "parses preface with errata" do
      xml = <<~XML
        <preface>
          <abstract id="_abs"><title>Abstract</title><p>Text</p></abstract>
          <errata_clause id="_ec">
            <title>Errata</title>
            <errata>
              <row>
                <date>2024-01-01</date>
                <type>typographical</type>
                <change>Fixed typo</change>
                <pages>5</pages>
              </row>
            </errata>
          </errata_clause>
        </preface>
      XML

      preface = described_class.from_xml(xml)
      expect(preface.abstract).not_to be_nil
      expect(preface.errata_clause.length).to eq(1)
    end
  end

  describe Metanorma::NistDocument::Sections::ErrataClause do
    it "inherits from ContentSection" do
      expect(described_class.superclass).to eq(
        Metanorma::StandardDocument::Sections::ContentSection,
      )
    end

    it "has errata attribute" do
      expect(described_class.attributes.keys).to include(:errata)
    end

    it "parses errata_clause with nested errata" do
      xml = <<~XML
        <errata_clause id="_ec">
          <title>Errata</title>
          <p>Some preamble</p>
          <errata>
            <row>
              <date>2024-01-01</date>
              <type>typographical</type>
              <change>Fixed typo</change>
              <pages>5</pages>
            </row>
          </errata>
        </errata_clause>
      XML

      clause = described_class.from_xml(xml)
      expect(clause.id).to eq("_ec")
      expect(clause.errata).not_to be_nil
      expect(clause.errata.rows.length).to eq(1)
      expect(clause.errata.rows.first.date).to eq("2024-01-01")
    end
  end

  describe Metanorma::NistDocument::Sections::Errata do
    it "parses errata with rows" do
      xml = <<~XML
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
      XML

      errata = described_class.from_xml(xml)
      expect(errata.rows.length).to eq(2)
      expect(errata.rows.first.date).to eq("2024-01-01")
      expect(errata.rows.last.type).to eq("technical")
    end
  end

  # ============================================================
  # Generic — sections collection: true + misccontainer
  # ============================================================

  describe "Generic" do
    subject { resolve_class("Metanorma::GenericDocument::Root") }

    before(:all) { require "metanorma/generic_document" }

    it "has sections as collection" do
      expect(subject.attributes[:sections].collection).to be(true)
    end

    it "has misccontainer attribute" do
      expect(subject.attributes.keys).to include(:misccontainer)
    end

    it "uses StandardDocument preface" do
      expect(subject.attributes[:preface].type).to eq(
        Metanorma::StandardDocument::Sections::Preface,
      )
    end

    it "uses StandardDocument bibdata" do
      expect(subject.attributes[:bibdata].type).to eq(
        Metanorma::StandardDocument::Metadata::StandardBibData,
      )
    end
  end

  # ============================================================
  # UN — custom UnSections and UnPreface
  # ============================================================

  describe "UN" do
    subject { resolve_class("Metanorma::UnDocument::Root") }

    before(:all) { require "metanorma/un_document" }

    it "uses UnPreface" do
      expect(subject.attributes[:preface].type).to eq(
        Metanorma::UnDocument::Sections::UnPreface,
      )
    end

    it "uses UnSections" do
      expect(subject.attributes[:sections].type).to eq(
        Metanorma::UnDocument::Sections::UnSections,
      )
    end

    it "uses StandardDocument annex" do
      expect(subject.attributes[:annex].type).to eq(
        Metanorma::StandardDocument::Sections::AnnexSection,
      )
    end
  end

  describe Metanorma::UnDocument::Sections::UnPreface do
    it "composes from Serializable (restrictive classes must not inherit)" do
      expect(described_class.superclass).to eq(
        Lutaml::Model::Serializable,
      )
    end

    it "types abstract as UnAbstractSection (UN Basic-Section)" do
      expect(described_class.attributes[:abstract].type).to eq(
        Metanorma::UnDocument::Sections::UnAbstractSection,
      )
    end

    it "parses preface with abstract, foreword, introduction" do
      xml = <<~XML
        <preface>
          <abstract id="_abs"><title>Abstract</title><p>Text</p></abstract>
          <foreword id="_fw"><title>Foreword</title><p>Foreword text</p></foreword>
          <introduction id="_intro"><title>Introduction</title><p>Intro</p></introduction>
        </preface>
      XML

      preface = described_class.from_xml(xml)
      expect(preface.abstract).not_to be_nil
      expect(preface.abstract).to be_a(
        Metanorma::UnDocument::Sections::UnAbstractSection,
      )
      expect(preface.foreword).not_to be_nil
      expect(preface.introduction).not_to be_nil
    end
  end

  describe Metanorma::UnDocument::Sections::UnSections do
    it "inherits from StandardDocument Sections" do
      expect(described_class.superclass).to eq(
        Metanorma::StandardDocument::Sections::Sections,
      )
    end

    it "parses sections with clauses and floating-titles only" do
      xml = <<~XML
        <sections>
          <clause id="_c1"><title>Scope</title><p>Text</p></clause>
          <floating-title depth="2">Note</floating-title>
          <clause id="_c2"><title>Details</title><p>More text</p></clause>
        </sections>
      XML

      sections = described_class.from_xml(xml)
      expect(sections.clause.length).to eq(2)
      expect(sections.floating_title.length).to eq(1)
    end
  end

  # ============================================================
  # Shared RootAttributes
  # ============================================================

  describe "All flavors include RootAttributes" do
    [
      "Metanorma::IsoDocument::Root",
      "Metanorma::OgcDocument::Root",
      "Metanorma::IeeeDocument::Root",
      "Metanorma::NistDocument::Root",
      "Metanorma::GenericDocument::Root",
      "Metanorma::UnDocument::Root",
      "Metanorma::BsiDocument::Root",
      "Metanorma::M3dDocument::Root",
    ].each do |class_name|
      it "#{class_name} has common root attributes" do
        klass = resolve_class(class_name)
        attrs = klass.attributes.keys
        expect(attrs).to include(:bibliography, :metanorma_extension, :type,
                                 :version, :schema_version)
      end
    end
  end

  # ============================================================
  # Register setup — lutaml_default_register per flavor
  # ============================================================

  describe "Flavor registers" do
    {
      "Metanorma::IsoDocument::Root" => :iso_document,
      "Metanorma::IecDocument::Root" => :iec_document,
      "Metanorma::OimlDocument::Root" => :oiml_document,
      "Metanorma::CsaDocument::Root" => :csa_document,
      "Metanorma::BsiDocument::Root" => :bsi_document,
      "Metanorma::JisDocument::Root" => :jis_document,
      "Metanorma::GbDocument::Root" => :gb_document,
      "Metanorma::PlateauDocument::Root" => :plateau_document,
      "Metanorma::IeeeDocument::Root" => :ieee_document,
      "Metanorma::IetfDocument::Root" => :ietf_document,
      "Metanorma::NistDocument::Root" => :nist_document,
      "Metanorma::UnDocument::Root" => :un_document,
      "Metanorma::M3dDocument::Root" => :m3d_document,
    }.each do |class_name, register_id|
      it "#{class_name} declares lutaml_default_register :#{register_id}" do
        klass = resolve_class(class_name)
        expect(klass.lutaml_default_register).to eq(register_id)
      end

      it ":#{register_id} register exists in GlobalRegister" do
        expect(Lutaml::Model::GlobalRegister.lookup(register_id)).not_to be_nil
      end
    end

    it "isodoc-family flavors without register use :default" do
      %w[
        Metanorma::OgcDocument::Root
        Metanorma::CcDocument::Root
        Metanorma::RiboseDocument::Root
        Metanorma::IhoDocument::Root
        Metanorma::BipmDocument::Root
        Metanorma::ItuDocument::Root
        Metanorma::GenericDocument::Root
      ].each do |class_name|
        klass = resolve_class(class_name)
        expect(klass.lutaml_default_register).to be_nil
      end
    end

    describe "ISO register type substitutions" do
      let(:register) { Lutaml::Model::GlobalRegister.lookup(:iso_document) }

      it "substitutes ClauseSection → IsoClauseSection" do
        expect(register.substitutable?(
                 Metanorma::StandardDocument::Sections::ClauseSection,
               )).to be true
      end

      it "substitutes AnnexSection → IsoAnnexSection" do
        expect(register.substitutable?(
                 Metanorma::StandardDocument::Sections::AnnexSection,
               )).to be true
      end

      it "substitutes Sections → IsoSections" do
        expect(register.substitutable?(
                 Metanorma::StandardDocument::Sections::Sections,
               )).to be true
      end

      it "substitutes Preface → IsoPreface" do
        expect(register.substitutable?(
                 Metanorma::StandardDocument::Sections::Preface,
               )).to be true
      end
    end

    describe "IEC register fallback" do
      let(:register) { Lutaml::Model::GlobalRegister.lookup(:iec_document) }

      it "falls back to :iso_document" do
        expect(register.fallback).to include(:iso_document)
      end
    end

    describe "Plateau register fallback chain" do
      let(:register) do
        Lutaml::Model::GlobalRegister.lookup(:plateau_document)
      end

      it "falls back to :jis_document" do
        expect(register.fallback).to include(:jis_document)
      end
    end

    describe "IETF register type substitutions" do
      let(:register) { Lutaml::Model::GlobalRegister.lookup(:ietf_document) }

      it "substitutes ClauseSection → IetfClauseSection" do
        expect(register.substitutable?(
                 Metanorma::StandardDocument::Sections::ClauseSection,
               )).to be true
      end

      it "substitutes AnnexSection → IetfAnnexSection" do
        expect(register.substitutable?(
                 Metanorma::StandardDocument::Sections::AnnexSection,
               )).to be true
      end

      it "substitutes Sections → IetfSections" do
        expect(register.substitutable?(
                 Metanorma::StandardDocument::Sections::Sections,
               )).to be true
      end

      it "substitutes ContentSection → IetfContentSection" do
        expect(register.substitutable?(
                 Metanorma::StandardDocument::Sections::ContentSection,
               )).to be true
      end
    end

    describe "BSI register type substitutions" do
      let(:register) { Lutaml::Model::GlobalRegister.lookup(:bsi_document) }

      it "substitutes IsoSections → BsiSections" do
        expect(register.substitutable?(
                 Metanorma::IsoDocument::Sections::IsoSections,
               )).to be true
      end

      it "substitutes IsoClauseSection → BsiClauseSection" do
        expect(register.substitutable?(
                 Metanorma::IsoDocument::Sections::IsoClauseSection,
               )).to be true
      end

      it "substitutes IsoAnnexSection → BsiAnnexSection" do
        expect(register.substitutable?(
                 Metanorma::IsoDocument::Sections::IsoAnnexSection,
               )).to be true
      end
    end

    describe "JIS register type substitutions" do
      let(:register) { Lutaml::Model::GlobalRegister.lookup(:jis_document) }

      it "substitutes IsoAnnexSection → JisAnnexSection" do
        expect(register.substitutable?(
                 Metanorma::IsoDocument::Sections::IsoAnnexSection,
               )).to be true
      end

      it "falls back to :iso_document" do
        expect(register.fallback).to include(:iso_document)
      end
    end

    describe "GB register fallback" do
      let(:register) { Lutaml::Model::GlobalRegister.lookup(:gb_document) }

      it "falls back to :iso_document" do
        expect(register.fallback).to include(:iso_document)
      end
    end

    describe "OIML register fallback" do
      let(:register) { Lutaml::Model::GlobalRegister.lookup(:oiml_document) }

      it "falls back to :iso_document" do
        expect(register.fallback).to include(:iso_document)
      end
    end

    describe "CSA register fallback" do
      let(:register) { Lutaml::Model::GlobalRegister.lookup(:csa_document) }

      it "falls back to :iso_document" do
        expect(register.fallback).to include(:iso_document)
      end
    end

    describe "M3D register" do
      let(:register) { Lutaml::Model::GlobalRegister.lookup(:m3d_document) }

      it "does not fall back to :iso_document" do
        expect(register.fallback).not_to include(:iso_document)
      end
    end
  end

  # ============================================================
  # Cross-dependency fix: StandardDocument types
  # ============================================================

  # ============================================================
  # Add/Del elements — moved to Document layer
  # ============================================================

  describe "Add/Del elements in Document layer" do
    describe Metanorma::Document::Elements::Add do
      it "parses add element with semx-id" do
        xml = '<add semx-id="s1" original-id="o1">added text</add>'
        add = described_class.from_xml(xml)
        expect(add.semx_id).to eq("s1")
        expect(add.original_id).to eq("o1")
      end
    end

    describe Metanorma::Document::Elements::Del do
      it "parses del element" do
        xml = '<del semx-id="s2" original-id="o2">deleted text</del>'
        del = described_class.from_xml(xml)
        expect(del.semx_id).to eq("s2")
        expect(del.original_id).to eq("o2")
      end
    end

    it "StandardDocument::Elements::Add is aliased to Document::Elements::Add" do
      expect(Metanorma::StandardDocument::Elements::Add).to eq(
        Metanorma::Document::Elements::Add,
      )
    end

    it "StandardDocument::Elements::Del is aliased to Document::Elements::Del" do
      expect(Metanorma::StandardDocument::Elements::Del).to eq(
        Metanorma::Document::Elements::Del,
      )
    end

    it "paragraph_block uses add/del from Document layer" do
      xml = '<p id="_p1">Text <add>added</add> and <del>removed</del></p>'
      p = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(xml)
      expect(p.add.length).to eq(1)
      expect(p.del.length).to eq(1)
    end
  end

  describe "StandardDocument type ownership" do
    describe Metanorma::StandardDocument::Boilerplate do
      it "is defined in StandardDocument" do
        expect(described_class).not_to be_nil
      end

      it "is aliased in IsoDocument for backwards compatibility" do
        expect(Metanorma::IsoDocument::Boilerplate).to eq(
          described_class,
        )
      end

      it "parses boilerplate content" do
        xml = '<boilerplate><copyright-statement><clause id="cs1" obligation="normative"><title>Copyright</title><p>Legal text</p></clause></copyright-statement></boilerplate>'
        bp = described_class.from_xml(xml)
        expect(bp.copyright_statement).not_to be_empty
        cs = bp.copyright_statement.first
        expect(cs.subsection).not_to be_empty
        expect(cs.subsection.first.paragraphs.first.text.first).to include("Legal text")
      end
    end

    describe Metanorma::StandardDocument::AnnotationContainer do
      it "is defined in StandardDocument" do
        expect(described_class).not_to be_nil
      end

      it "is aliased in IsoDocument for backwards compatibility" do
        expect(Metanorma::IsoDocument::AnnotationContainer).to eq(
          described_class,
        )
      end
    end

    describe Metanorma::StandardDocument::Metadata::MetanormaExtension do
      it "is defined in StandardDocument" do
        expect(described_class).not_to be_nil
      end

      it "is aliased in IsoDocument for backwards compatibility" do
        expect(Metanorma::IsoDocument::Metadata::MetanormaExtension).to eq(
          described_class,
        )
      end
    end

    describe Metanorma::StandardDocument::Terms::TermExpression do
      it "is defined in StandardDocument" do
        expect(described_class).not_to be_nil
      end

      it "is aliased in IsoDocument for backwards compatibility" do
        expect(Metanorma::IsoDocument::Terms::TermExpression).to eq(
          described_class,
        )
      end

      it "parses term expression with name" do
        xml = "<expression><name>test term</name></expression>"
        expr = described_class.from_xml(xml)
        expect(expr.name.length).to eq(1)
      end
    end

    describe Metanorma::StandardDocument::Terms::TermNameElement do
      it "is aliased in IsoDocument for backwards compatibility" do
        expect(Metanorma::IsoDocument::Terms::TermNameElement).to eq(
          described_class,
        )
      end
    end

    describe Metanorma::StandardDocument::Sections::Colophon do
      it "is defined in StandardDocument" do
        expect(described_class).not_to be_nil
      end

      it "is aliased in IsoDocument for backwards compatibility" do
        expect(Metanorma::IsoDocument::Sections::Colophon).to eq(
          described_class,
        )
      end

      it "uses ClauseSection for sub-clauses (register substitution handles flavor override)" do
        expect(described_class.attributes[:clause].type).to(
          eq(Metanorma::StandardDocument::Sections::ClauseSection),
        )
      end

      it "parses colophon with clauses" do
        xml = <<~XML
          <colophon>
            <clause id="_c1"><title>Production</title><p>Printed by...</p></clause>
          </colophon>
        XML
        colophon = described_class.from_xml(xml)
        expect(colophon.clause.length).to eq(1)
        expect(colophon.clause.first.id).to eq("_c1")
      end
    end
  end

  # ============================================================
  # Base type completeness (no flavor overrides needed)
  # ============================================================

  describe "Base types satisfy flavor requirements" do
    describe Metanorma::StandardDocument::Sections::ClauseSection do
      it "has unnumbered attribute" do
        expect(described_class.attributes.keys).to include(:unnumbered)
      end

      it "has ordered mode for blocks AND subsections" do
        xml = <<~XML
          <clause id="_c1">
            <title>Test</title>
            <p>Block text</p>
            <clause id="_c2"><title>Sub</title><p>Sub text</p></clause>
          </clause>
        XML
        clause = described_class.from_xml(xml)
        expect(clause.paragraphs.length).to eq(1)
        expect(clause.clause.length).to eq(1)
      end
    end

    describe Metanorma::StandardDocument::Sections::AnnexSection do
      it "has unnumbered attribute" do
        expect(described_class.attributes.keys).to include(:unnumbered)
      end

      it "has terms attribute" do
        expect(described_class.attributes.keys).to include(:terms)
      end

      it "has definitions attribute" do
        expect(described_class.attributes.keys).to include(:definitions)
      end

      it "has references attribute" do
        expect(described_class.attributes.keys).to include(:references)
      end
    end

    describe Metanorma::Document::Components::Lists::OrderedList do
      it "has class_attr for ITU/NIST steps" do
        expect(described_class.attributes.keys).to include(:class_attr)
      end

      it "has start attribute for BIPM" do
        expect(described_class.attributes.keys).to include(:start)
      end

      it "parses ol with class=steps" do
        xml = '<ol class="steps"><li><p>Step 1</p></li></ol>'
        ol = described_class.from_xml(xml)
        expect(ol.class_attr).to eq("steps")
      end
    end

    describe Metanorma::Document::Components::AncillaryBlocks::FigureBlock do
      it "has pre attribute for M3D ASCII art" do
        expect(described_class.attributes.keys).to include(:pre)
      end

      it "parses figure with pre element" do
        xml = <<~XML
                  <figure id="_f1">
                    <pre id="_pre1">  +---+
          | A |
          +---+</pre>
                  </figure>
        XML
        figure = described_class.from_xml(xml)
        expect(figure.id).to eq("_f1")
        expect(figure.pre).not_to be_nil
      end
    end
  end

  # ============================================================
  # GB — ISO-family with fallback register
  # ============================================================

  describe "GB register and round-trip" do
    let(:register) { Lutaml::Model::GlobalRegister.lookup(:gb_document) }

    it "falls back to :iso_document" do
      expect(register.fallback).to include(:iso_document)
    end

    it "parses GB document with ISO sections" do
      xml = <<~XML
        <metanorma type="semantic" version="1.0">
          <bibdata type="standard">
            <title>GB Standard</title>
          </bibdata>
          <sections>
            <clause id="_c1"><title>Scope</title><p>Text</p></clause>
            <terms id="_t1">
              <title>Terms</title>
              <p>Boilerplate paragraph</p>
              <ul><li><p>List item</p></li></ul>
              <term id="_term1">
                <preferred><expression><name>test term</name></expression></preferred>
                <definition><p>A definition</p></definition>
              </term>
            </terms>
          </sections>
        </metanorma>
      XML

      doc = Metanorma::GbDocument::Root.from_xml(xml)
      expect(doc.sections.clause.length).to eq(1)
      expect(doc.sections.terms).not_to be_nil
      expect(doc.sections.terms.p.length).to eq(1)
      expect(doc.sections.terms.ul.length).to eq(1)
      expect(doc.sections.terms.term.length).to eq(1)
    end

    it "parses GB annex with ISO annex structure" do
      xml = <<~XML
        <metanorma type="semantic" version="1.0">
          <bibdata type="standard"><title>GB</title></bibdata>
          <annex id="_a1" obligation="informative">
            <title>Appendix</title>
            <clause id="_c1"><title>Details</title><p>Text</p></clause>
          </annex>
        </metanorma>
      XML

      doc = Metanorma::GbDocument::Root.from_xml(xml)
      expect(doc.annex.length).to eq(1)
      expect(doc.annex.first.id).to eq("_a1")
    end
  end

  # ============================================================
  # UN — unnumbered on base types
  # ============================================================

  describe "UN unnumbered attributes" do
    it "parses UN clause with unnumbered" do
      xml = <<~XML
        <clause id="_c1" unnumbered="true">
          <title>Unnumbered Section</title>
          <p>Some text</p>
        </clause>
      XML

      clause = Metanorma::StandardDocument::Sections::ClauseSection.from_xml(xml)
      expect(clause.unnumbered).to be(true)
    end

    it "parses UN annex with unnumbered" do
      xml = <<~XML
        <annex id="_a1" obligation="informative" unnumbered="true">
          <title>Unnumbered Annex</title>
          <p>Content</p>
        </annex>
      XML

      annex = Metanorma::StandardDocument::Sections::AnnexSection.from_xml(xml)
      expect(annex.unnumbered).to be(true)
      expect(annex.obligation).to eq("informative")
    end
  end

  # ============================================================
  # IHO — annex accepts terms/definitions/references
  # ============================================================

  describe "IHO annex verification" do
    it "annex accepts terms inside" do
      xml = <<~XML
        <annex id="_a1" obligation="informative">
          <title>Appendix</title>
          <terms id="_t1">
            <title>Terms</title>
            <term id="_term1">
              <preferred><expression><name>term</name></expression></preferred>
            </term>
          </terms>
          <definitions id="_d1"><title>Definitions</title></definitions>
        </annex>
      XML

      annex = Metanorma::StandardDocument::Sections::AnnexSection.from_xml(xml)
      expect(annex.terms.length).to eq(1)
      expect(annex.definitions.length).to eq(1)
    end
  end

  # ============================================================
  # BIPM/ITU — ClauseSection allows blocks AND subsections
  # ============================================================

  describe "BIPM/ITU ClauseSection body model" do
    it "base ClauseSection accepts blocks AND subsections simultaneously" do
      xml = <<~XML
        <clause id="_c1">
          <title>Test</title>
          <p>Block text</p>
          <table id="_t1"><tbody><tr><td>Cell</td></tr></tbody></table>
          <clause id="_c2"><title>Sub</title><p>Sub text</p></clause>
          <terms id="_t2"><title>Terms</title></terms>
          <definitions id="_d1"><title>Defs</title></definitions>
        </clause>
      XML

      clause = Metanorma::StandardDocument::Sections::ClauseSection.from_xml(xml)
      expect(clause.paragraphs.length).to eq(1)
      expect(clause.tables.length).to eq(1)
      expect(clause.clause.length).to eq(1)
      expect(clause.terms.length).to eq(1)
      expect(clause.definitions.length).to eq(1)
    end

    it "base ClauseSection accepts blocks-only (no subsections)" do
      xml = <<~XML
        <clause id="_c1">
          <title>Blocks only</title>
          <p>First paragraph</p>
          <p>Second paragraph</p>
          <ul><li><p>Item</p></li></ul>
        </clause>
      XML

      clause = Metanorma::StandardDocument::Sections::ClauseSection.from_xml(xml)
      expect(clause.paragraphs.length).to eq(2)
      expect(clause.unordered_lists.length).to eq(1)
      expect(clause.clause.length).to eq(0)
    end

    it "base ClauseSection accepts subsections-only (no blocks)" do
      xml = <<~XML
        <clause id="_c1">
          <title>Subsections only</title>
          <clause id="_c2"><title>Sub A</title><p>Text</p></clause>
          <clause id="_c3"><title>Sub B</title><p>More</p></clause>
        </clause>
      XML

      clause = Metanorma::StandardDocument::Sections::ClauseSection.from_xml(xml)
      expect(clause.paragraphs.length).to eq(0)
      expect(clause.clause.length).to eq(2)
    end
  end

  # ============================================================
  # BSI — Admonition target attribute
  # ============================================================

  describe "BSI Admonition target" do
    it "admonition has target attribute" do
      expect(Metanorma::Document::Components::MultiParagraph::AdmonitionBlock
        .attributes.keys).to include(:target)
    end

    it "admonition has unnumbered attribute" do
      expect(Metanorma::Document::Components::MultiParagraph::AdmonitionBlock
        .attributes.keys).to include(:unnumbered)
    end

    it "parses admonition with target and unnumbered" do
      xml = <<~XML
        <admonition id="_ad1" type="commentary" target="_s1" unnumbered="true">
          <p>Commentary text</p>
        </admonition>
      XML

      adm = Metanorma::Document::Components::MultiParagraph::AdmonitionBlock.from_xml(xml)
      expect(adm.type).to eq("commentary")
      expect(adm.target).to eq("_s1")
      expect(adm.unnumbered).to be(true)
    end

    it "round-trips admonition with target" do
      xml = '<admonition id="_ad1" type="commentary" target="_s1"><p>Text</p></admonition>'
      adm = Metanorma::Document::Components::MultiParagraph::AdmonitionBlock.from_xml(xml)
      expect(adm.to_xml).to include('target="_s1"')
      expect(adm.to_xml).to include('type="commentary"')
    end
  end

  # ============================================================
  # IETF — ContentSection with numbered/removeInRFC
  # ============================================================

  describe "IETF preface content section round-trip" do
    it "parses IETF preface with numbered content sections" do
      xml = <<~XML
        <preface>
          <abstract id="_abs" numbered="true" removeInRFC="false">
            <title>Abstract</title>
            <p>Abstract text</p>
          </abstract>
          <foreword id="_fw" numbered="true">
            <title>Foreword</title>
            <p>Foreword text</p>
          </foreword>
          <introduction id="_intro" numbered="false" removeInRFC="true">
            <title>Introduction</title>
            <p>Intro text</p>
            <clause id="_sub" numbered="false">
              <title>Sub-intro</title>
              <p>Sub text</p>
            </clause>
          </introduction>
        </preface>
      XML

      preface = Metanorma::StandardDocument::Sections::Preface.from_xml(xml)
      expect(preface.abstract).not_to be_nil
      expect(preface.foreword).not_to be_nil
      expect(preface.introduction).not_to be_nil
    end
  end

  # ============================================================
  # IETF — All base attributes complete
  # ============================================================

  describe "IETF attribute completeness" do
    it "ParagraphBlock has keep-with-next" do
      expect(Metanorma::Document::Components::Paragraphs::ParagraphBlock
        .attributes.keys).to include(:keep_with_next)
    end

    it "ParagraphBlock has align" do
      expect(Metanorma::Document::Components::Paragraphs::ParagraphBlock
        .attributes.keys).to include(:alignment)
    end

    it "NoteBlock has removeInRFC" do
      expect(Metanorma::Document::Components::Blocks::NoteBlock
        .attributes.keys).to include(:remove_in_rfc)
    end

    it "ErefElement has all IETF attributes" do
      attrs = Metanorma::Document::Components::Inline::ErefElement.attributes.keys
      expect(attrs).to include(:normative, :alt, :display_format, :relative)
    end

    it "SourcecodeBlock has markers" do
      expect(Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
        .attributes.keys).to include(:markers)
    end

    it "XrefElement has format" do
      expect(Metanorma::Document::Components::Inline::XrefElement
        .attributes.keys).to include(:format)
    end
  end

  # ============================================================
  # SectionXmlMapping DRY helpers
  # ============================================================

  describe "SectionXmlMapping helpers" do
    describe "sections container mapping" do
      it "SD::Sections parses all core elements via apply_sections_elements" do
        xml = <<~XML
          <sections>
            <clause id="_c1"><title>A</title><p>Text</p></clause>
            <terms id="_t1"><title>Terms</title></terms>
            <definitions id="_d1"><title>Defs</title></definitions>
            <floating-title depth="2">Note</floating-title>
            <references id="_r1"><title>Refs</title></references>
          </sections>
        XML
        sections = Metanorma::StandardDocument::Sections::Sections.from_xml(xml)
        expect(sections.clause.length).to eq(1)
        expect(sections.terms.length).to eq(1)
        expect(sections.definitions.length).to eq(1)
        expect(sections.floating_title.length).to eq(1)
        expect(sections.references.length).to eq(1)
      end

      it "IsoSections adds ISO-specific elements on top of base" do
        xml = <<~XML
          <sections>
            <note id="_n1"><p>Note text</p></note>
            <admonition id="_ad1" type="warning"><p>Admonition</p></admonition>
            <clause id="_c1"><title>Scope</title><p>Text</p></clause>
            <p>Lead paragraph</p>
          </sections>
        XML
        sections = Metanorma::IsoDocument::Sections::IsoSections.from_xml(xml)
        expect(sections.note.length).to eq(1)
        expect(sections.admonition.length).to eq(1)
        expect(sections.clause.length).to eq(1)
        expect(sections.p.length).to eq(1)
      end
    end

    describe "preface container mapping" do
      it "SD::Preface parses all preface sections via apply_preface_elements" do
        xml = <<~XML
          <preface>
            <abstract id="_abs"><title>Abstract</title><p>Text</p></abstract>
            <foreword id="_fw"><title>Foreword</title><p>FW</p></foreword>
            <introduction id="_intro"><title>Intro</title><p>Intro</p></introduction>
            <acknowledgements id="_ack"><title>Ack</title><p>Ack</p></acknowledgements>
            <executivesummary id="_es"><title>ES</title><p>ES</p></executivesummary>
            <clause id="_c1"><title>Custom</title><p>Custom</p></clause>
          </preface>
        XML
        preface = Metanorma::StandardDocument::Sections::Preface.from_xml(xml)
        expect(preface.abstract).not_to be_nil
        expect(preface.foreword).not_to be_nil
        expect(preface.introduction).not_to be_nil
        expect(preface.acknowledgements).not_to be_nil
        expect(preface.executivesummary).not_to be_nil
        expect(preface.content.length).to eq(1)
      end
    end

    describe "content section mapping" do
      it "ContentSection parses via apply_content_section helpers" do
        xml = <<~XML
          <clause id="_cs1" anchor="cs1" type="scope" number="1"
                  obligation="normative" inline-header="false"
                  semx-id="s1" autonum="1." displayorder="1">
            <title>Scope</title>
            <p>Content text</p>
            <clause id="_cs2"><title>Sub</title><p>Sub text</p></clause>
          </clause>
        XML
        cs = Metanorma::StandardDocument::Sections::ContentSection.from_xml(xml)
        expect(cs.id).to eq("_cs1")
        expect(cs.anchor).to eq("cs1")
        expect(cs.type).to eq("scope")
        expect(cs.number).to eq("1")
        expect(cs.obligation).to eq("normative")
        expect(cs.inline_header).to be(false)
        expect(cs.semx_id).to eq("s1")
        expect(cs.autonum).to eq("1.")
        expect(cs.displayorder).to eq(1)
        expect(cs.paragraphs.length).to eq(1)
        expect(cs.subsection.length).to eq(1)
      end

      it "IetfContentSection adds numbered/removeInRFC on top of base mapping" do
        xml = <<~XML
          <clause id="_ic1" numbered="true" removeInRFC="false">
            <title>Section</title>
            <p>Text</p>
            <clause id="_ic2" numbered="false"><title>Sub</title><p>More</p></clause>
          </clause>
        XML
        ics = Metanorma::IetfDocument::Sections::IetfContentSection.from_xml(xml)
        expect(ics.numbered).to eq("true")
        expect(ics.remove_in_rfc).to be(false)
        expect(ics.paragraphs.length).to eq(1)
        expect(ics.subsection.length).to eq(1)
        expect(ics.subsection.first).to be_a(Metanorma::IetfDocument::Sections::IetfContentSection)
      end
    end
  end

  # ============================================================
  # ContentSection subclass attribute inheritance
  # ============================================================

  describe "ContentSection subclasses inherit attributes" do
    describe Metanorma::StandardDocument::Sections::Foreword do
      it "inherits semx_id from ContentSection" do
        expect(described_class.attributes.keys).to include(:semx_id)
      end

      it "inherits displayorder from ContentSection" do
        expect(described_class.attributes.keys).to include(:displayorder)
      end

      it "adds original_id" do
        expect(described_class.attributes.keys).to include(:original_id)
      end
    end

    describe Metanorma::StandardDocument::Sections::Introduction do
      it "inherits semx_id from ContentSection" do
        expect(described_class.attributes.keys).to include(:semx_id)
      end

      it "inherits autonum from ContentSection" do
        expect(described_class.attributes.keys).to include(:autonum)
      end

      it "adds original_id" do
        expect(described_class.attributes.keys).to include(:original_id)
      end
    end

    describe Metanorma::StandardDocument::Sections::Abstract do
      it "inherits semx_id from ContentSection" do
        expect(described_class.attributes.keys).to include(:semx_id)
      end

      it "adds original_id" do
        expect(described_class.attributes.keys).to include(:original_id)
      end
    end
  end

  # ============================================================
  # IsoAnnexSection blocks method inherited
  # ============================================================

  describe "IsoAnnexSection blocks method" do
    it "inherits blocks method from SD::AnnexSection" do
      xml = <<~XML
        <annex id="_a1" obligation="informative">
          <title>Appendix</title>
          <p>First paragraph</p>
          <table id="_t1"><tbody><tr><td>Cell</td></tr></tbody></table>
          <p>Second paragraph</p>
          <clause id="_c1"><title>Sub</title><p>Sub text</p></clause>
        </annex>
      XML
      annex = Metanorma::IsoDocument::Sections::IsoAnnexSection.from_xml(xml)
      expect(annex.blocks.length).to eq(4)
      expect(annex.blocks.map(&:class).map(&:name)).to include(
        "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
        "Metanorma::Document::Components::Tables::TableBlock",
      )
    end
  end

  # ============================================================
  # IsoClauseSection direct parsing
  # ============================================================

  describe Metanorma::IsoDocument::Sections::IsoClauseSection do
    it "inherits from StandardDocument::ClauseSection" do
      expect(described_class.superclass).to eq(
        Metanorma::StandardDocument::Sections::ClauseSection,
      )
    end

    it "overrides clause to IsoClauseSection" do
      expect(described_class.attributes[:clause].type).to eq(described_class)
    end

    it "overrides terms to IsoTermsSection" do
      expect(described_class.attributes[:terms].type).to eq(
        Metanorma::IsoDocument::Sections::IsoTermsSection,
      )
    end

    it "parses nested clauses with ISO types" do
      xml = <<~XML
        <clause id="_c1" type="scope" obligation="normative">
          <title>Scope</title>
          <p>Scope text</p>
          <clause id="_c2"><title>Sub-scope</title><p>Detail</p></clause>
          <terms id="_t1">
            <title>Terms</title>
            <term id="_term1">
              <preferred><expression><name>iso term</name></expression></preferred>
            </term>
          </terms>
        </clause>
      XML
      clause = described_class.from_xml(xml)
      expect(clause.clause.first).to be_a(described_class)
      expect(clause.terms.length).to eq(1)
      expect(clause.terms.first).to be_a(Metanorma::IsoDocument::Sections::IsoTermsSection)
    end
  end

  # ============================================================
  # IsoPreface direct parsing
  # ============================================================

  describe Metanorma::IsoDocument::Sections::IsoPreface do
    it "composes from Serializable (restrictive classes must not inherit)" do
      expect(described_class.superclass).to eq(
        Lutaml::Model::Serializable,
      )
    end

    it "restricts attributes to the ISO grammar set" do
      expect(described_class.attributes.keys).to contain_exactly(
        :abstract, :foreword, :introduction, :clause, :content,
        :semx_id, :displayorder,
      )
    end

    it "uses IsoForewordSection for foreword" do
      expect(described_class.attributes[:foreword].type).to eq(
        Metanorma::IsoDocument::Sections::IsoForewordSection,
      )
    end

    it "uses IsoClauseSection for introduction" do
      expect(described_class.attributes[:introduction].type).to eq(
        Metanorma::IsoDocument::Sections::IsoClauseSection,
      )
    end

    it "uses IsoClauseSection for generic preface clauses" do
      expect(described_class.attributes[:clause].type).to eq(
        Metanorma::IsoDocument::Sections::IsoClauseSection,
      )
    end

    it "parses full ISO preface" do
      xml = <<~XML
        <preface>
          <abstract id="_abs"><title>Abstract</title><p>Abstract text</p></abstract>
          <foreword id="_fw"><title>Foreword</title><p>Foreword text</p></foreword>
          <introduction id="_intro"><title>Introduction</title><p>Intro</p></introduction>
          <clause id="_ded"><title>Dedication</title><p>Dedication</p></clause>
        </preface>
      XML
      preface = described_class.from_xml(xml)
      expect(preface.abstract).not_to be_nil
      expect(preface.foreword).to be_a(Metanorma::IsoDocument::Sections::IsoForewordSection)
      expect(preface.introduction).to be_a(Metanorma::IsoDocument::Sections::IsoClauseSection)
      expect(preface.clause.length).to eq(1)
      expect(preface.content.length).to eq(1)
    end

    it "serializes constructed prefaces in grammar order" do
      sections = Metanorma::IsoDocument::Sections
      preface = described_class.new(
        introduction: sections::IsoClauseSection.new(id: "_intro"),
        foreword: sections::IsoForewordSection.new(id: "_fw"),
        abstract: sections::IsoAbstractSection.new(id: "_abs"),
      )
      expect(preface.to_xml.index("<abstract")).to be < preface.to_xml.index("<foreword")
      expect(preface.to_xml.index("<foreword")).to be < preface.to_xml.index("<introduction")
    end

    it "drops acknowledgements forbidden by the ISO grammar" do
      xml = <<~XML
        <preface>
          <foreword id="_fw"><title>Foreword</title><p>Text</p></foreword>
          <acknowledgements id="_ack"><p>Ack</p></acknowledgements>
        </preface>
      XML
      preface = described_class.from_xml(xml)
      expect(preface.to_xml).not_to include("acknowledgements")
    end
  end

  # ============================================================
  # Architectural invariants
  # ============================================================

  describe "Architectural invariants" do
    it "RootAttributes references only StandardDocument types" do
      source = File.read("lib/metanorma/standard_document/root_attributes.rb")
      expect(source).not_to include("IsoDocument")
    end

    it "StandardDocument code has zero IsoDocument references" do
      sd_files = Dir.glob("lib/metanorma/standard_document/**/*.rb")
      sd_files.each do |f|
        source = File.read(f)
        expect(source).not_to include("IsoDocument"),
                              "StandardDocument file #{f} references IsoDocument"
      end
    end

    it "no respond_to? usage in the codebase" do
      rb_files = Dir.glob("lib/metanorma/**/*.rb")
      offenders = rb_files.select do |f|
        File.read(f).include?("respond_to?")
      end
      expect(offenders).to be_empty,
                           "Files using respond_to?: #{offenders.join(', ')}"
    end

    it "no private send usage in the codebase" do
      rb_files = Dir.glob("lib/metanorma/**/*.rb")
      offenders = rb_files.select do |f|
        source = File.read(f)
        source.match?(/\b\.send\b/)
      end
      expect(offenders).to be_empty,
                           "Files using private .send: #{offenders.join(', ')}"
    end

    # Document layer should not reference higher layers (StandardDocument/IsoDocument).
    # Known violations are listed explicitly — adding more is a regression.
    it "Document layer has no NEW upward references beyond known violations" do
      doc_files = Dir.glob("lib/metanorma/document/**/*.rb")

      doc_files.each do |f|
        source = File.read(f)
        expect(source).not_to include("StandardDocument"),
                              "Document file #{f} references StandardDocument"
        expect(source).not_to include("IsoDocument"),
                              "Document file #{f} references IsoDocument"
      end
    end

    it "no internal require for metanorma code (autoload only)" do
      rb_files = Dir.glob("lib/metanorma/**/*.rb")
      offenders = rb_files.select do |f|
        source = File.read(f)
        source.match?(/require\s+["']metanorma\//)
      end
      expect(offenders).to be_empty,
                           "Files using require for internal metanorma code: #{offenders.join(', ')}"
    end

    it "no require_relative in model code" do
      rb_files = Dir.glob("lib/metanorma/{document,standard_document,*_document,basic_document}/**/*.rb")
      offenders = rb_files.select do |f|
        source = File.read(f)
        source.include?("require_relative")
      end
      expect(offenders).to be_empty,
                           "Files using require_relative: #{offenders.join(', ')}"
    end

    it "no __send__ or public_send in model code" do
      model_files = Dir.glob("lib/metanorma/{document,standard_document,*_document}/**/*.rb")
      offenders = model_files.select do |f|
        source = File.read(f)
        source.match?(/(__send__|public_send)/)
      end
      expect(offenders).to be_empty,
                           "Model files using __send__/public_send: #{offenders.join(', ')}"
    end

    it "no cross-flavor contamination in flavor-specific directories" do
      flavors = Dir.glob("lib/metanorma/*_document/").map do |d|
        File.basename(d)
      end
      flavor_names = flavors.map { |f| f.sub("_document", "") }

      flavors.each_with_index do |flavor_dir, idx|
        own_name = flavor_names[idx]
        other_names = flavor_names.reject { |n| n == own_name }

        Dir.glob("#{flavor_dir}**/*.rb").each do |f|
          source = File.read(f)
          other_names.each do |other|
            other_dir = "#{other}_document"
            expect(source).not_to include(other_dir),
                                  "#{f} references #{other_dir} (cross-flavor contamination)"
          end
        end
      end
    end

    it "no raw Object or BasicObject types in attribute declarations" do
      rb_files = Dir.glob("lib/metanorma/**/*.rb")
      offenders = rb_files.select do |f|
        source = File.read(f)
        source.match?(/attribute\s+\w+,\s*(Object|BasicObject)\b/)
      end
      expect(offenders).to be_empty,
                           "Files with raw Object/BasicObject types: #{offenders.join(', ')}"
    end

    it "registers/setup.rb has no module-level autoload triggers" do
      source = File.read("lib/metanorma/registers/setup.rb")
      # Module-level constants like SD = Metanorma::SomeDocument trigger
      # autoloads during module body evaluation, causing circular dependencies.
      # All constant resolution must be inside method bodies.
      expect(source).not_to match(/^\s{4,6}\w+\s*=\s*Metanorma::/),
                            "setup.rb has module-level constant assignment that triggers autoload"
    end

    it "ContentSection has unnumbered, toc, class_attr attributes" do
      cs = Metanorma::StandardDocument::Sections::ContentSection
      attrs = cs.attributes
      expect(attrs).to have_key(:unnumbered),
                       "ContentSection missing unnumbered attribute"
      expect(attrs).to have_key(:toc),
                       "ContentSection missing toc attribute"
      expect(attrs).to have_key(:class_attr),
                       "ContentSection missing class_attr attribute"
    end

    it "all section types using apply_content_section_attributes have unnumbered/toc/class_attr" do
      # Any class that uses apply_content_section_attributes must declare
      # unnumbered, toc, and class_attr (or inherit them from ContentSection).
      sd_files = Dir.glob("lib/metanorma/{standard_document,*_document}/**/*.rb")
      sd_files.each do |f|
        source = File.read(f)
        next unless source.include?("apply_content_section_attributes")
        next if source.include?("< Metanorma::StandardDocument::Sections::ContentSection")
        next if source.include?("def self.apply_content_section_attributes")

        expect(source).to match(/attribute\s+:unnumbered/),
                          "#{f} uses apply_content_section_attributes but lacks :unnumbered"
        expect(source).to match(/attribute\s+:toc/),
                          "#{f} uses apply_content_section_attributes but lacks :toc"
        expect(source).to match(/attribute\s+:class_attr/),
                          "#{f} uses apply_content_section_attributes but lacks :class_attr"
      end
    end

    it "PresentationAttributes mixin provides all presentation attrs" do
      # Test against ClauseSection which includes PresentationAttributes
      cls = Metanorma::StandardDocument::Sections::ClauseSection
      attrs = cls.attributes
      %i[anchor semx_id autonum displayorder fmt_title
         fmt_xref_label variant_title fmt_annotation_start fmt_annotation_end].each do |attr|
        expect(attrs).to have_key(attr),
                         "ClauseSection (includes PresentationAttributes) missing :#{attr}"
      end
    end

    it "OrderedContent mixin provides blocks method" do
      cls = Metanorma::StandardDocument::Sections::ClauseSection
      expect(cls.instance_methods).to include(:blocks)
    end

    it "no section type declares individual presentation attrs when using PresentationAttributes" do
      sd_files = Dir.glob("lib/metanorma/standard_document/sections/*.rb")
      sd_files.each do |f|
        source = File.read(f)
        next unless source.include?("PresentationAttributes")

        expect(source).not_to match(/attribute\s+:semx_id/),
                              "#{f} includes PresentationAttributes but re-declares :semx_id"
        expect(source).not_to match(/attribute\s+:autonum/),
                              "#{f} includes PresentationAttributes but re-declares :autonum"
        expect(source).not_to match(/attribute\s+:displayorder/),
                              "#{f} includes PresentationAttributes but re-declares :displayorder"
        expect(source).not_to match(/attribute\s+:fmt_title,/),
                              "#{f} includes PresentationAttributes but re-declares :fmt_title"
        expect(source).not_to match(/attribute\s+:fmt_xref_label/),
                              "#{f} includes PresentationAttributes but re-declares :fmt_xref_label"
        expect(source).not_to match(/attribute\s+:variant_title/),
                              "#{f} includes PresentationAttributes but re-declares :variant_title"
        expect(source).not_to match(/attribute\s+:fmt_annotation_start/),
                              "#{f} includes PresentationAttributes but re-declares :fmt_annotation_start"
        expect(source).not_to match(/attribute\s+:fmt_annotation_end/),
                              "#{f} includes PresentationAttributes but re-declares :fmt_annotation_end"
      end
    end

    it "no rescue StandardError in model code" do
      model_files = Dir.glob("lib/metanorma/{document,standard_document,*_document,basic_document}/**/*.rb")
      offenders = model_files.select do |f|
        File.read(f).include?("rescue StandardError")
      end
      expect(offenders).to be_empty,
                           "Model files using rescue StandardError: #{offenders.join(', ')}"
    end

    # map_all_content is only allowed for inherently arbitrary XML content.
    # All structured content must use typed element mappings.
    it "no map_all_content except whitelisted legitimate uses" do
      whitelist = %w[
        math_element.rb
        semx_child_element.rb
        sourcecode_block.rb
        sourcecode_body.rb
        organization.rb
        bipm_bibliographic_item.rb
        bipm_depiction_element.rb
        depiction_element.rb
        logo_element.rb
      ]
      model_files = Dir.glob("lib/metanorma/{document,standard_document,*_document,basic_document}/**/*.rb")
      offenders = model_files.select do |f|
        next false if whitelist.any? { |w| f.end_with?(w) }

        File.read(f).include?("map_all_content")
      end
      expect(offenders).to be_empty,
                           "Files with map_all_content (not whitelisted): #{offenders.join(', ')}"
    end

    it "no RawParagraph class exists" do
      rb_files = Dir.glob("lib/metanorma/**/*.rb")
      offenders = rb_files.select do |f|
        source = File.read(f)
        source.include?("RawParagraph")
      end
      expect(offenders).to be_empty,
                           "Files referencing RawParagraph: #{offenders.join(', ')}"
    end

    # Boolean attributes must use :boolean type, not :string
    it "no boolean-valued attributes typed as :string" do
      boolean_attrs = %w[unnumbered keep_with_next keep_with_previous
                         keep_lines_together remove_in_rfc inline_header
                         hidden hiddenref commentary]
      rb_files = Dir.glob("lib/metanorma/{document,standard_document,*_document}/**/*.rb")
      offenders = rb_files.flat_map do |f|
        source = File.read(f)
        boolean_attrs.select do |attr|
          source.match?(/attribute\s+:#{attr},\s*:string/)
        end.map { |attr| "#{f}: #{attr}" }
      end
      expect(offenders).to be_empty,
                           "Boolean attrs typed as :string: #{offenders.join(', ')}"
    end
  end

  # ============================================================
  # Document-layer type specs
  # ============================================================

  describe "Document-layer types" do
    describe Metanorma::Document::Components::Blocks::Passthrough do
      it "parses and round-trips passthrough XML" do
        xml = '<passthrough id="_pt1" formats="html,pdf">content here</passthrough>'
        pt = described_class.from_xml(xml)
        expect(pt.id).to eq("_pt1")
        expect(pt.formats).to eq("html,pdf")
        expect(pt.content).to eq("content here")
        expect(pt.to_xml).to be_equivalent_to(xml)
      end

      it "is aliased as StandardDocument::Blocks::Passthrough" do
        expect(Metanorma::StandardDocument::Blocks::Passthrough).to eq(described_class)
      end
    end

    describe Metanorma::Document::Components::Blocks::RequirementModel do
      it "parses a requirement with classification and description" do
        xml = <<~XML
          <requirement id="_req1" model="ogc" obligation="requirement" type="general">
            <subject>test subject</subject>
            <classification><tag>type</tag><value>general</value></classification>
            <description><p>Req description</p></description>
          </requirement>
        XML
        req = described_class.from_xml(xml)
        expect(req.id).to eq("_req1")
        expect(req.model).to eq("ogc")
        expect(req.obligation).to eq("requirement")
        expect(req.type).to eq("general")
        expect(req.subject).to eq("test subject")
        expect(req.classification.length).to eq(1)
        expect(req.classification.first.tag).to eq("type")
        expect(req.description.length).to eq(1)
      end

      it "is aliased as StandardDocument::Blocks::RequirementModel" do
        expect(Metanorma::StandardDocument::Blocks::RequirementModel).to eq(described_class)
      end
    end

    describe Metanorma::Document::Components::Blocks::RecommendationModel do
      it "parses a recommendation element" do
        xml = '<recommendation id="_rec1"><subject>test</subject></recommendation>'
        rec = described_class.from_xml(xml)
        expect(rec.id).to eq("_rec1")
        expect(rec.subject).to eq("test")
      end

      it "is aliased as StandardDocument::Blocks::RecommendationModel" do
        expect(Metanorma::StandardDocument::Blocks::RecommendationModel).to eq(described_class)
      end
    end

    describe Metanorma::Document::Components::Blocks::PermissionModel do
      it "parses a permission element" do
        xml = '<permission id="_perm1"><subject>test</subject></permission>'
        perm = described_class.from_xml(xml)
        expect(perm.id).to eq("_perm1")
        expect(perm.subject).to eq("test")
      end

      it "is aliased as StandardDocument::Blocks::PermissionModel" do
        expect(Metanorma::StandardDocument::Blocks::PermissionModel).to eq(described_class)
      end
    end

    describe Metanorma::Document::Components::ReferenceElements::SourceElement do
      it "parses a source element with origin" do
        xml = <<~XML
          <source id="_src1" status="modified" type="authoritative">
            <origin bibitemid="ref1" type="inline" citeas="ISO 9001"/>
          </source>
        XML
        src = described_class.from_xml(xml)
        expect(src.id).to eq("_src1")
        expect(src.status).to eq("modified")
        expect(src.type).to eq("authoritative")
        expect(src.origin).not_to be_nil
        expect(src.origin.bibitemid).to eq("ref1")
        expect(src.origin.citeas).to eq("ISO 9001")
      end

      it "parses a source with modification" do
        xml = <<~XML
          <source status="modified">
            <origin bibitemid="ref1" citeas="ISO 9001"/>
            <modification id="_mod1"><p>Modified text</p></modification>
          </source>
        XML
        src = described_class.from_xml(xml)
        expect(src.modification).not_to be_nil
        expect(src.modification.id).to eq("_mod1")
      end

      it "is aliased as IsoDocument::Terms::TermSource" do
        expect(Metanorma::IsoDocument::Terms::TermSource).to eq(described_class)
      end
    end

    describe Metanorma::IsoDocument::Terms::TermsourceElement do
      it "parses termsource element with origin" do
        xml = <<~XML
          <termsource id="_ts1" status="modified" type="authoritative">
            <origin bibitemid="ref1" citeas="ISO 9001"/>
          </termsource>
        XML
        ts = described_class.from_xml(xml)
        expect(ts.id).to eq("_ts1")
        expect(ts.status).to eq("modified")
        expect(ts.origin).not_to be_nil
        expect(ts.origin.citeas).to eq("ISO 9001")
      end
    end

    describe Metanorma::StandardDocument::Sections::MiscContainer do
      it "parses misc-container with legacy presentation-metadata" do
        xml = '<misc-container semx-id="_mc1" original-id="mc1" displayorder="1">' \
              "<presentation-metadata><name>TOC Heading Levels</name>" \
              "<value>2</value></presentation-metadata></misc-container>"
        mc = described_class.from_xml(xml)
        expect(mc.semx_id).to eq("_mc1")
        expect(mc.original_id).to eq("mc1")
        expect(mc.displayorder).to eq(1)
        expect(mc.presentation_metadata.length).to eq(1)
        expect(mc.presentation_metadata.first.name).to eq("TOC Heading Levels")
        expect(mc.presentation_metadata.first.value).to eq("2")
      end

      it "round-trips in generic document root" do
        xml = <<~XML
          <metanorma type="semantic" version="1.0">
            <bibdata type="standard"><title>Test</title></bibdata>
            <sections><clause id="_s1"><title>S</title><p>Text</p></clause></sections>
            <misc-container semx-id="_mc1"><presentation-metadata><name>TOC Heading Levels</name><value>2</value></presentation-metadata></misc-container>
          </metanorma>
        XML
        root = Metanorma::GenericDocument::Root.from_xml(xml)
        expect(root.misccontainer).not_to be_nil
        expect(root.misccontainer.semx_id).to eq("_mc1")
        expect(root.misccontainer.presentation_metadata.first.value).to eq("2")
      end
    end

    describe Metanorma::Document::Components::ContribMetadata::ContributionElementMetadata do
      it "parses with integrity-value children" do
        xml = <<~XML
          <contribution-element-metadata date-time="2024-01-01">
            <contributor/>
            <integrity-value/>
          </contribution-element-metadata>
        XML
        obj = described_class.from_xml(xml)
        expect(obj.date_time).to eq("2024-01-01")
        expect(obj.integrity_value.length).to eq(1)
      end
    end
  end

  # ============================================================
  # Round-trip specs for all flavor roots
  # ============================================================

  describe "Flavor root round-trip parsing" do
    # Minimal valid XML for StandardDocument-based flavors
    let(:standard_doc_xml) do
      <<~XML
        <metanorma type="semantic" version="1.0">
          <bibdata type="standard">
            <title>Test Document</title>
          </bibdata>
          <sections>
            <clause id="_scope"><title>Scope</title><p>Test scope text</p></clause>
          </sections>
        </metanorma>
      XML
    end

    # Minimal valid XML with annex
    let(:standard_doc_with_annex_xml) do
      <<~XML
        <metanorma type="semantic" version="1.0">
          <bibdata type="standard">
            <title>Test</title>
          </bibdata>
          <sections>
            <clause id="_c1"><title>Scope</title><p>Text</p></clause>
          </sections>
          <annex id="_a1" obligation="informative">
            <title>Appendix</title>
            <clause id="_ac1"><title>Detail</title><p>Detail text</p></clause>
          </annex>
        </metanorma>
      XML
    end

    def round_trip(root_class, xml)
      doc = root_class.from_xml(xml)
      output = doc.to_xml
      reparsed = root_class.from_xml(output)
      [doc, reparsed, output]
    end

    # --- ISO-family round-trips ---

    describe "ISO" do
      it "round-trips a minimal document" do
        doc, reparsed, output = round_trip(
          Metanorma::IsoDocument::Root, standard_doc_with_annex_xml
        )
        expect(doc.sections.clause.length).to eq(1)
        expect(doc.annex.length).to eq(1)
        expect(doc.type).to eq("semantic")
        expect(reparsed.sections.clause.length).to eq(1)
        expect(reparsed.annex.length).to eq(1)
        expect(output).to include('<clause id="_c1"')
        expect(output).to include('<annex id="_a1"')
      end
    end

    describe "IEC" do
      it "round-trips using ISO fallback" do
        doc, reparsed, output = round_trip(
          Metanorma::IecDocument::Root, standard_doc_with_annex_xml
        )
        expect(doc.sections.clause.length).to eq(1)
        expect(doc.annex.length).to eq(1)
        expect(reparsed.sections.clause.length).to eq(1)
        expect(output).to include("semantic")
      end
    end

    describe "OIML" do
      it "round-trips using ISO fallback" do
        doc, reparsed, = round_trip(
          Metanorma::OimlDocument::Root, standard_doc_with_annex_xml
        )
        expect(doc.sections.clause.length).to eq(1)
        expect(doc.annex.length).to eq(1)
        expect(reparsed.sections.clause.length).to eq(1)
      end
    end

    describe "GB" do
      it "round-trips using ISO fallback" do
        doc, reparsed, = round_trip(
          Metanorma::GbDocument::Root, standard_doc_with_annex_xml
        )
        expect(doc.sections.clause.length).to eq(1)
        expect(doc.annex.length).to eq(1)
        expect(reparsed.annex.length).to eq(1)
      end
    end

    # --- BSI — ISO-family with custom sections ---

    describe "BSI" do
      it "round-trips with floating-section-title" do
        xml = <<~XML
          <metanorma type="semantic" version="1.0">
            <bibdata type="standard"><title>BSI Doc</title></bibdata>
            <sections>
              <section-title id="_ft1" depth="2">Preamble</section-title>
              <clause id="_c1"><title>Scope</title><p>Text</p></clause>
            </sections>
          </metanorma>
        XML

        doc, reparsed, output = round_trip(
          Metanorma::BsiDocument::Root, xml
        )
        expect(doc.sections.floating_section_title.length).to eq(1)
        expect(doc.sections.clause.length).to eq(1)
        expect(reparsed.sections.floating_section_title.length).to eq(1)
        expect(output).to include("section-title")
      end

      it "round-trips with annex containing floating-section-title" do
        xml = <<~XML
          <metanorma type="semantic" version="1.0">
            <bibdata type="standard"><title>BSI Doc</title></bibdata>
            <sections><clause id="_c1"><title>Scope</title><p>Text</p></clause></sections>
            <annex id="_a1" obligation="informative">
              <title>Appendix</title>
              <section-title id="_ft1" depth="1">Note</section-title>
              <clause id="_ac1"><title>Detail</title><p>Detail</p></clause>
            </annex>
          </metanorma>
        XML

        doc, reparsed, output = round_trip(
          Metanorma::BsiDocument::Root, xml
        )
        expect(doc.annex.length).to eq(1)
        expect(reparsed.annex.length).to eq(1)
        expect(output).to include("section-title")
      end
    end

    # --- JIS — ISO-family with commentary annex ---

    describe "JIS" do
      it "round-trips with commentary annex" do
        xml = <<~XML
          <metanorma type="semantic" version="1.0">
            <bibdata type="standard"><title>JIS Doc</title></bibdata>
            <sections><clause id="_c1"><title>Scope</title><p>Text</p></clause></sections>
            <annex id="_a1" obligation="informative" commentary="true">
              <title>Commentary</title>
              <clause id="_ac1"><title>Notes</title><p>Commentary text</p></clause>
            </annex>
          </metanorma>
        XML

        doc, reparsed, output = round_trip(
          Metanorma::JisDocument::Root, xml
        )
        expect(doc.annex.length).to eq(1)
        expect(doc.annex.first.commentary).to be(true)
        expect(reparsed.annex.first.commentary).to be(true)
        expect(output).to include('commentary="true"')
      end
    end

    # --- Plateau — JIS-family fallback ---

    describe "Plateau" do
      it "round-trips using JIS fallback chain" do
        doc, reparsed, = round_trip(
          Metanorma::PlateauDocument::Root, standard_doc_with_annex_xml
        )
        expect(doc.sections.clause.length).to eq(1)
        expect(doc.annex.length).to eq(1)
        expect(reparsed.annex.length).to eq(1)
      end
    end

    # --- StandardDocument-family round-trips ---

    {
      ogc: Metanorma::OgcDocument::Root,
      cc: Metanorma::CcDocument::Root,
      ribose: Metanorma::RiboseDocument::Root,
      iho: Metanorma::IhoDocument::Root,
      bipm: Metanorma::BipmDocument::Root,
      itu: Metanorma::ItuDocument::Root,
      m3d: Metanorma::M3dDocument::Root,
    }.each do |flavor, root_class|
      describe flavor.upcase do
        it "round-trips a minimal document" do
          doc, reparsed, output = round_trip(root_class,
                                             standard_doc_with_annex_xml)
          expect(doc.sections.clause.length).to eq(1)
          expect(doc.annex.length).to eq(1)
          expect(reparsed.sections.clause.length).to eq(1)
          expect(output).to include("semantic")
        end
      end
    end

    # --- IEEE — custom IeeeSections with note ---

    describe "IEEE" do
      it "round-trips with sections-level note" do
        xml = <<~XML
          <metanorma type="semantic" version="1.0">
            <bibdata type="standard"><title>IEEE Doc</title></bibdata>
            <sections>
              <note id="_n1"><p>Document-level note</p></note>
              <clause id="_c1"><title>Scope</title><p>Text</p></clause>
            </sections>
          </metanorma>
        XML

        doc, reparsed, output = round_trip(
          Metanorma::IeeeDocument::Root, xml
        )
        expect(doc.sections.note).not_to be_nil
        expect(doc.sections.clause.length).to eq(1)
        expect(reparsed.sections.clause.length).to eq(1)
        expect(output).to include("<note")
      end
    end

    # --- IETF — custom IetfSections with numbered/removeInRFC ---

    describe "IETF" do
      it "round-trips with numbered clauses and annex" do
        xml = <<~XML
          <metanorma type="semantic" version="1.0">
            <bibdata type="standard"><title>RFC Doc</title></bibdata>
            <sections>
              <clause id="_c1" numbered="true" removeInRFC="false">
                <title>Scope</title><p>Text</p>
              </clause>
            </sections>
            <annex id="_a1" obligation="informative" numbered="true">
              <title>Appendix</title><p>Appendix text</p>
            </annex>
          </metanorma>
        XML

        doc, reparsed, output = round_trip(
          Metanorma::IetfDocument::Root, xml
        )
        expect(doc.sections.clause.length).to eq(1)
        expect(doc.sections.clause.first.numbered).to eq("true")
        expect(doc.annex.length).to eq(1)
        expect(doc.annex.first.numbered).to eq("true")
        expect(reparsed.annex.first.numbered).to eq("true")
        expect(output).to include('numbered="true"')
      end
    end

    # --- NIST — custom NistPreface with errata ---

    describe "NIST" do
      it "round-trips with errata in preface" do
        xml = <<~XML
          <metanorma type="semantic" version="1.0">
            <bibdata type="standard"><title>NIST Doc</title></bibdata>
            <preface>
              <abstract id="_abs"><title>Abstract</title><p>Text</p></abstract>
              <errata_clause id="_ec">
                <title>Errata</title>
                <errata>
                  <row>
                    <date>2024-01-01</date>
                    <type>typo</type>
                    <change>Fix</change>
                    <pages>5</pages>
                  </row>
                </errata>
              </errata_clause>
            </preface>
            <sections>
              <clause id="_c1"><title>Scope</title><p>Text</p></clause>
            </sections>
          </metanorma>
        XML

        doc, reparsed, output = round_trip(
          Metanorma::NistDocument::Root, xml
        )
        expect(doc.preface.abstract).not_to be_nil
        expect(doc.preface.errata_clause.length).to eq(1)
        expect(reparsed.preface.errata_clause.length).to eq(1)
        expect(output).to include("errata")
      end
    end

    # --- UN — custom UnSections, UnPreface ---

    describe "UN" do
      it "round-trips with unnumbered sections" do
        xml = <<~XML
          <metanorma type="semantic" version="1.0">
            <bibdata type="standard"><title>UN Doc</title></bibdata>
            <sections>
              <clause id="_c1" unnumbered="true"><title>Preamble</title><p>Text</p></clause>
              <clause id="_c2"><title>Scope</title><p>Scope text</p></clause>
            </sections>
            <annex id="_a1" obligation="informative" unnumbered="true">
              <title>Appendix</title><p>Text</p>
            </annex>
          </metanorma>
        XML

        doc, reparsed, output = round_trip(
          Metanorma::UnDocument::Root, xml
        )
        expect(doc.sections.clause.length).to eq(2)
        expect(doc.annex.length).to eq(1)
        expect(doc.annex.first.unnumbered).to be(true)
        expect(reparsed.annex.first.unnumbered).to be(true)
        expect(output).to include('unnumbered="true"')
      end
    end

    # --- Generic — collection sections + misccontainer ---

    describe "Generic" do
      it "round-trips with multiple sections" do
        xml = <<~XML
          <metanorma type="semantic" version="1.0">
            <bibdata type="standard"><title>Generic Doc</title></bibdata>
            <sections>
              <clause id="_c1"><title>Part 1</title><p>Text</p></clause>
            </sections>
            <sections>
              <clause id="_c2"><title>Part 2</title><p>More text</p></clause>
            </sections>
            <annex id="_a1" obligation="informative">
              <title>Appendix</title><p>Text</p>
            </annex>
          </metanorma>
        XML

        doc, reparsed, output = round_trip(
          Metanorma::GenericDocument::Root, xml
        )
        expect(doc.sections.length).to eq(2)
        expect(doc.annex.length).to eq(1)
        expect(reparsed.sections.length).to eq(2)
        expect(reparsed.annex.length).to eq(1)
        expect(output).to include("semantic")
      end
    end
  end
end
