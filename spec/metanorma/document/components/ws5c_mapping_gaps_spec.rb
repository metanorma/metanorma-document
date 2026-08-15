# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "WS5c mapping gaps (#44, #46)" do
  describe "@anchor on xref target carriers" do
    it "maps anchor on td/th/tr, fn, term, name, title, variant-title, dd, definition, image, annotation, pre, span" do
      cases = {
        Metanorma::Document::Components::Inline::FnElement => '<fn id="_fn1" anchor="fn-anchor"><p>note</p></fn>',
        Metanorma::StandardDocument::Terms::Term => '<term id="_t1" anchor="term-anchor"><preferred><expression><name>x</name></expression></preferred></term>',
        Metanorma::Document::Components::Inline::NameWithIdElement => '<name id="_n1" anchor="name-anchor">Figure 1</name>',
        Metanorma::Document::Components::Inline::TitleWithAnnotationElement => '<title id="_ti1" anchor="title-anchor">Scope</title>',
        Metanorma::Document::Components::Inline::VariantTitleElement => '<variant-title type="sub" anchor="vt-anchor">Alt</variant-title>',
        Metanorma::Document::Components::Lists::DdElement => '<dd id="_dd1" anchor="dd-anchor"><p>desc</p></dd>',
        Metanorma::Document::Components::IdElements::Image => '<image id="_im1" anchor="img-anchor" src="x.png"/>',
        Metanorma::Document::Components::AncillaryBlocks::LiteralBlock => '<pre id="_pre1" anchor="pre-anchor">text</pre>',
        Metanorma::Document::Components::Inline::SpanElement => '<span anchor="span-anchor">styled</span>',
      }

      cases.each do |klass, xml|
        expect(klass.from_xml(xml).anchor).to(
          eq(xml[/anchor="([^"]+)"/, 1]),
          "expected @anchor to map on #{klass.name}",
        )
      end

      row = Metanorma::Document::Components::Tables::TextTableRow.from_xml(
        '<tr id="_tr1" anchor="tr-anchor"><td id="_td1" anchor="td-anchor">cell</td><th id="_th1" anchor="th-anchor">head</th></tr>',
      )
      expect(row.anchor).to eq("tr-anchor")
      expect(row.td.first.anchor).to eq("td-anchor")
      expect(row.th.first.anchor).to eq("th-anchor")

      annotation = Metanorma::StandardDocument::AnnotationContainer::Annotation
        .from_xml('<annotation id="_a1" anchor="ann-anchor" reviewer="RV"><p>comment</p></annotation>')
      expect(annotation.anchor).to eq("ann-anchor")
    end
  end

  describe "inline date and fmt-date" do
    it "maps value/format and the rendered form in body content" do
      xml = <<~XML
        <p>Published <date value="2020-01-01" format="dd MMM yyyy"/> on <fmt-date><semx element="date" source="_d1">1 Jan 2020</semx></fmt-date>.</p>
      XML

      para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(xml)

      expect(para.date.first.value).to eq("2020-01-01")
      expect(para.date.first.format).to eq("dd MMM yyyy")
      expect(para.fmt_date.first.semx.first.text).to eq(["1 Jan 2020"])
    end
  end

  describe "bibitem display attributes" do
    it "maps hidden and suppress_identifier" do
      xml = <<~XML
        <bibitem id="_b1" hidden="true" suppress_identifier="true">
          <formattedref format="text/plain">Some Reference</formattedref>
        </bibitem>
      XML

      bibitem = Metanorma::Document::Components::BibData::BibliographicItem.from_xml(xml)

      expect(bibitem.hidden).to be(true)
      expect(bibitem.suppress_identifier).to be(true)
    end
  end

  describe "erefstack" do
    it "maps the element and its connective eref children" do
      xml = <<~XML
        <erefstack id="_es1">
          <eref bibitemid="R1" citeas="RFC 1" connective="to"/>
          <eref bibitemid="R2" citeas="RFC 2" custom-connective="and"/>
        </erefstack>
      XML

      stack = Metanorma::Document::Components::Inline::ErefStack.from_xml(xml)

      expect(stack.id).to eq("_es1")
      expect(stack.eref.size).to eq(2)
      expect(stack.eref.first.connective).to eq("to")
      expect(stack.eref.last.custom_connective).to eq("and")
    end

    it "maps erefstack in body content and as concept child" do
      para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(
        "<p>See <erefstack><eref bibitemid=\"R1\" citeas=\"RFC 1\"/></erefstack>.</p>",
      )
      concept = Metanorma::StandardDocument::Terms::Concept.from_xml(
        "<concept ital='true'><refterm>widget</refterm><erefstack><eref bibitemid='R1' citeas='RFC 1'/></erefstack></concept>",
      )

      expect(para.erefstack.first.eref.first.bibitemid).to eq("R1")
      expect(concept.erefstack.eref.first.bibitemid).to eq("R1")
    end
  end

  describe "concept semantic carriers" do
    it "maps bold/ital/ref/linkmention/linkref and termref children" do
      xml = <<~XML
        <concept bold="true" ital="true" ref="false" linkmention="true" linkref="true">
          <refterm>widget</refterm>
          <renderterm>widgets</renderterm>
          <termref base="ISO-termbase" target="3.1">widget</termref>
        </concept>
      XML

      concept = Metanorma::StandardDocument::Terms::Concept.from_xml(xml)

      expect(concept.bold).to be(true)
      expect(concept.ital).to be(true)
      expect(concept.ref).to be(false)
      expect(concept.linkmention).to be(true)
      expect(concept.linkref).to be(true)
      expect(concept.termref.base).to eq("ISO-termbase")
      expect(concept.termref.target).to eq("3.1")
      expect(concept.termref.text).to eq(["widget"])
    end

    it "maps the same carriers on the inline concept element" do
      xml = <<~XML
        <concept ital="true" ref="true" linkmention="false" linkref="false" bold="true">
          <refterm>widget</refterm><renderterm>widgets</renderterm>
          <eref bibitemid="ISO712" citeas="ISO 712"/>
        </concept>
      XML

      concept = Metanorma::Document::Components::Inline::ConceptElement.from_xml(xml)

      expect(concept.bold).to be(true)
      expect(concept.ital).to be(true)
      expect(concept.ref).to be(true)
      expect(concept.eref.bibitemid).to eq("ISO712")
    end
  end

  describe "errormsg" do
    it "maps errormsg as concept final choice with pure-text content" do
      xml = <<~XML
        <concept ital="true"><refterm>widget</refterm><errormsg>Unresolved reference to <em>widget</em>!</errormsg></concept>
      XML

      concept = Metanorma::Document::Components::Inline::ConceptElement.from_xml(xml)

      expect(concept.errormsg).to be_a(Metanorma::Document::Components::Inline::ErrorMessage)
      expect(concept.errormsg.text).to include("Unresolved reference to ")
      expect(concept.errormsg.em.size).to eq(1)
    end

    it "maps errormsg inside related" do
      xml = <<~XML
        <related type="contrast"><errormsg>no match found</errormsg></related>
      XML

      related = Metanorma::StandardDocument::Terms::RelatedTerm.from_xml(xml)

      expect(related.errormsg.text).to eq(["no match found"])
    end
  end
end
