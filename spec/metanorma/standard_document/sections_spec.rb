# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "StandardDocument section models" do
  describe Metanorma::StandardDocument::Sections::ClauseSection do
    it "parses a clause with blocks" do
      xml = <<~XML
        <clause id="_c1" type="scope" obligation="normative">
          <title>Scope</title>
          <p id="_p1">This is the scope paragraph.</p>
          <table id="_t1"><thead><tr><th>Header</th></tr></thead><tbody><tr><td>Cell</td></tr></tbody></table>
          <figure id="_f1"><name>Figure 1</name></figure>
        </clause>
      XML

      clause = described_class.from_xml(xml)

      clause.id.should eq("_c1")
      clause.type.should eq("scope")
      clause.obligation.should eq("normative")
      clause.paragraphs.length.should eq(1)
      clause.tables.length.should eq(1)
      clause.figures.length.should eq(1)
    end

    it "parses nested clauses recursively" do
      xml = <<~XML
        <clause id="_c1">
          <title>Clause 1</title>
          <p>Top-level paragraph</p>
          <clause id="_c1_1">
            <title>Clause 1.1</title>
            <p>Nested paragraph</p>
          </clause>
        </clause>
      XML

      clause = described_class.from_xml(xml)

      clause.id.should eq("_c1")
      clause.clause.length.should eq(1)
      clause.clause.first.id.should eq("_c1_1")
      clause.clause.first.paragraphs.length.should eq(1)
    end

    it "parses terms and definitions inside a clause" do
      xml = <<~XML
        <clause id="_c1">
          <title>Terms</title>
          <terms id="_terms1">
            <title>Terms and definitions</title>
            <term id="_t1">
              <preferred><expression><name>term name</name></expression></preferred>
            </term>
          </terms>
          <definitions id="_defs1">
            <title>Symbols</title>
          </definitions>
        </clause>
      XML

      clause = described_class.from_xml(xml)

      clause.terms.length.should eq(1)
      clause.definitions.length.should eq(1)
    end
  end

  describe Metanorma::StandardDocument::Sections::Sections do
    it "parses sections with mixed content types" do
      xml = <<~XML
        <sections>
          <clause id="_scope"><title>Scope</title><p>Scope text</p></clause>
          <terms id="_terms"><title>Terms</title><term id="_t1"><preferred><expression><name>term</name></expression></preferred></term></terms>
          <definitions id="_defs"><title>Symbols</title><dl><dt>A</dt><dd><p>Alpha</p></dd></dl></definitions>
          <floating-title depth="2">Note</floating-title>
          <references normative="true" id="_normrefs"><title>Normative References</title></references>
        </sections>
      XML

      sections = described_class.from_xml(xml)

      sections.clause.length.should eq(1)
      sections.terms.length.should eq(1)
      sections.definitions.length.should eq(1)
      sections.floating_title.length.should eq(1)
      sections.references.length.should eq(1)
    end
  end

  describe Metanorma::StandardDocument::Sections::Preface do
    it "parses a preface with abstract and foreword" do
      xml = <<~XML
        <preface>
          <abstract id="_abs"><title>Abstract</title><p>Abstract text</p></abstract>
          <foreword id="_fw"><title>Foreword</title><p>Foreword text</p></foreword>
          <introduction id="_intro"><title>Introduction</title><p>Intro text</p></introduction>
        </preface>
      XML

      preface = described_class.from_xml(xml)

      preface.abstract.should_not be_nil
      preface.foreword.should_not be_nil
      preface.introduction.should_not be_nil
    end

    it "parses generic clause content in preface" do
      xml = <<~XML
        <preface>
          <abstract id="_abs"><title>Abstract</title><p>Text</p></abstract>
          <clause id="_misc"><title>Dedication</title><p>Dedication text</p></clause>
        </preface>
      XML

      preface = described_class.from_xml(xml)

      preface.content.length.should eq(1)
    end
  end

  describe Metanorma::StandardDocument::Sections::AnnexSection do
    it "parses an annex with blocks and sub-clauses" do
      xml = <<~XML
        <annex id="_a1" obligation="informative">
          <title>Annex A</title>
          <p>Annex content</p>
          <clause id="_a1_1">
            <title>A.1</title>
            <p>Subclause content</p>
          </clause>
        </annex>
      XML

      annex = described_class.from_xml(xml)

      annex.id.should eq("_a1")
      annex.obligation.should eq("informative")
      annex.paragraphs.length.should eq(1)
      annex.clause.length.should eq(1)
    end

    it "parses an annex with recursive sub-annexes" do
      xml = <<~XML
        <annex id="_a1" obligation="normative">
          <title>Annex B</title>
          <clause id="_b1">
            <title>B.1</title>
            <p>Content</p>
            <clause id="_b1_1"><title>B.1.1</title><p>Deep nested</p></clause>
          </clause>
        </annex>
      XML

      annex = described_class.from_xml(xml)

      annex.clause.first.clause.length.should eq(1)
    end
  end

  describe Metanorma::StandardDocument::Sections::ContentSection do
    it "parses a content section with blocks and subsections" do
      xml = <<~XML
        <clause id="_cs1">
          <title>Introduction</title>
          <p>Some text</p>
          <clause id="_cs1_1">
            <title>Background</title>
            <p>Background text</p>
          </clause>
        </clause>
      XML

      section = described_class.from_xml(xml)

      section.paragraphs.length.should eq(1)
      section.subsection.length.should eq(1)
    end
  end

  describe Metanorma::StandardDocument::Sections::DefinitionSection do
    it "parses a definition section with definition lists" do
      xml = <<~XML
        <definitions id="_defs" type="symbols">
          <title>Symbols and abbreviated terms</title>
          <dl>
            <dt>A</dt>
            <dd><p>Alpha</p></dd>
            <dt>B</dt>
            <dd><p>Bravo</p></dd>
          </dl>
        </definitions>
      XML

      defs = described_class.from_xml(xml)

      defs.id.should eq("_defs")
      defs.type.should eq("symbols")
      defs.definition_lists.length.should eq(1)
    end
  end

  describe Metanorma::StandardDocument::Sections::TermsSection do
    it "parses a terms section with term entries" do
      xml = <<~XML
        <terms id="_terms">
          <title>Terms and definitions</title>
          <p>For the purposes of this document, the following terms apply.</p>
          <term id="_t1">
            <preferred><expression><name>example term</name></expression></preferred>
          </term>
        </terms>
      XML

      terms = described_class.from_xml(xml)

      terms.id.should eq("_terms")
      terms.paragraphs.length.should eq(1)
      terms.terms.length.should eq(1)
    end
  end

  describe Metanorma::StandardDocument::Sections::BibliographySection do
    it "references ClauseSection, not IsoClauseSection" do
      described_class.new
      described_class.attributes.keys.should include(:references, :clause)
    end

    it "parses a bibliography with references" do
      xml = <<~XML
        <bibliography>
          <references normative="true"><title>Normative References</title></references>
          <references normative="false"><title>Bibliography</title></references>
        </bibliography>
      XML

      bib = described_class.from_xml(xml)

      bib.references.length.should eq(2)
      bib.references.first.normative.should be(true)
      bib.references.last.normative.should be(false)
    end
  end
end

RSpec.describe "StandardDocument shared modules" do
  describe Metanorma::StandardDocument::BlockAttributes do
    it "adds block collection attributes when included" do
      klass = Class.new(Lutaml::Model::Serializable) do
        include Metanorma::StandardDocument::BlockAttributes
      end

      attrs = klass.attributes.keys
      attrs.should include(:paragraphs, :tables, :figures, :formulas,
                           :examples, :notes, :admonitions,
                           :sourcecode_blocks, :quote_blocks, :definition_lists)
    end
  end

  describe Metanorma::StandardDocument::RootAttributes do
    it "adds common root attributes when included" do
      klass = Class.new(Lutaml::Model::Serializable) do
        include Metanorma::StandardDocument::RootAttributes
      end

      attrs = klass.attributes.keys
      attrs.should include(:version, :type, :schema_version, :flavor,
                           :bibliography, :boilerplate, :metanorma_extension,
                           :autonum, :fmt_xref_label)
    end
  end

  describe Metanorma::StandardDocument::BlockXmlMapping do
    it "adds block element mappings via ClauseSection parsing" do
      clause_xml = <<~XML
        <clause id="_test">
          <p>Paragraph</p>
          <table id="_t"><thead><tr><th>H</th></tr></thead><tbody><tr><td>D</td></tr></tbody></table>
          <figure id="_f"><name>Fig</name></figure>
          <formula id="_fm"><stem type="MathML"><math></math></stem></formula>
          <note id="_n"><p>Note text</p></note>
        </clause>
      XML

      clause = Metanorma::StandardDocument::Sections::ClauseSection.from_xml(clause_xml)

      clause.paragraphs.length.should eq(1)
      clause.tables.length.should eq(1)
      clause.figures.length.should eq(1)
      clause.formulas.length.should eq(1)
      clause.notes.length.should eq(1)
    end
  end
end
