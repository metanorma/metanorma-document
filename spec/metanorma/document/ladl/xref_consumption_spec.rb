# frozen_string_literal: true

require "rspec"
require "nokogiri"
require_relative "../../../../lib/metanorma/document"
require "metanorma/standoc/document"
require "metanorma/iso/document"
require "metanorma/html"

RSpec.describe "Persisted native LADL cross-reference consumption" do
  before { Lutaml::Model::Config.xml_adapter_type = :nokogiri }

  def render_xref(document, target, text: nil, format: nil)
    renderer = Metanorma::Html::StandardRenderer.new
    renderer.document = document
    xref = Metanorma::Document::Components::Inline::XrefElement.new(target: target, text: text && [text], format: format)
    renderer.render_inline_element(xref)
  end

  it "uses native global/local metadata after actual ISO document XML roundtrip" do
    xml = '<metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation"><sections><clause id="c">' \
          '<fmt-xref-label container="ladl">Clause 2, NOTE<fmt-ladl-label-data local="NOTE" global="Clause 2, NOTE" value="1" labeller="note_labeller"/></fmt-xref-label></clause></sections></metanorma>'
    root = Metanorma::Iso::Document::Root.from_xml(xml)
    root = root.class.from_xml(root.to_xml)
    expect(render_xref(root, "c")).to include('href="#c"', ">Clause 2, NOTE</a>")
    expect(render_xref(root, "c", format: "local")).to include(">NOTE</a>")
    expect(render_xref(root, "c", text: "Authored reference")).to include(">Authored reference</a>")
  end

  it "reads common typed sibling metadata on a native list item without changing scalar label" do
    xml = '<metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation"><sections><clause><ol><li id="li" label="a)"><fmt-ladl-label-data local="a)" global="List 1 a)" value="a" labeller="list_item"/></li></ol></clause></sections></metanorma>'
    root = Metanorma::Standoc::Document::Root.from_xml(xml)
    root = root.class.from_xml(root.to_xml)
    expect(root.sections.clause.first.ordered_lists.first.listitem.first.label).to eq("a)")
    expect(render_xref(root, "li")).to include(">List 1 a)</a>")
  end

  it "escapes computed label data and preserves missing/unlabelled target fallback" do
    xml = '<metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation"><sections><clause id="c"><fmt-xref-label container="ladl"><fmt-ladl-label-data local="&lt;unsafe&gt;" labeller="test"/>' \
          '</fmt-xref-label></clause><clause id="old"/></sections></metanorma>'
    root = Metanorma::Standoc::Document::Root.from_xml(xml)
    expect(render_xref(root, "c")).to include("&lt;unsafe&gt;")
    expect(render_xref(root, "old")).to include(">[old]</a>")
    expect(render_xref(root, "missing", text: "Text")).to include(">[missing] Text</a>")
  end

  it "walks an unlabelled native graph once across many existing and missing references" do
    clauses = (1..240).map { |i| %(<clause id="c#{i}"/>) }.join
    xml = %(<metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation"><sections>#{clauses}</sections></metanorma>)
    root = Metanorma::Standoc::Document::Root.from_xml(xml)
    renderer = Metanorma::Html::StandardRenderer.new
    renderer.document = root
    allow(root).to receive(:sections).and_call_original
    24.times do
      found = Metanorma::Document::Components::Inline::XrefElement.new(target: "c240")
      missing = Metanorma::Document::Components::Inline::XrefElement.new(target: "missing", text: ["Authored"])
      expect(renderer.render_inline_element(found)).to eq('<a href="#c240">[c240]</a>')
      expect(renderer.render_inline_element(missing)).to eq('<a href="#missing">[missing] Authored</a>')
    end
    expect(root).to have_received(:sections).once
  end

  it "preserves first-match identity and reads replacement metadata without another graph scan" do
    xml = '<metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation"><sections><clause id="duplicate"/><clause id="duplicate"><fmt-xref-label><fmt-ladl-label-data local="Second"/>' \
          "</fmt-xref-label></clause></sections></metanorma>"
    root = Metanorma::Standoc::Document::Root.from_xml(xml)
    first = root.sections.clause.first
    renderer = Metanorma::Html::StandardRenderer.new
    renderer.document = root
    xref = Metanorma::Document::Components::Inline::XrefElement.new(target: "duplicate")
    allow(root).to receive(:sections).and_call_original
    expect(renderer.render_inline_element(xref)).to include(">[duplicate]</a>")
    inline = Metanorma::Document::Components::Inline
    first.fmt_xref_label = [inline::FmtXrefLabelElement.new(fmt_ladl_label_data: inline::FmtLadlLabelData.new(local: "Live local", global: "Live global"))]
    expect(renderer.render_inline_element(xref)).to include(">Live global</a>")
    first.fmt_xref_label.first.fmt_ladl_label_data.global = "Updated global"
    expect(renderer.render_inline_element(xref)).to include(">Updated global</a>")
    expect(root).to have_received(:sections).once
  end

  it "rebuilds for same-model edits and appended nodes through both render entrypoints and a different root" do
    make_root = lambda do |label|
      xml = '<metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation"><bibdata type="standard"><title language="en">Index lifecycle</title><docidentifier>TEST</docidentifier>' \
            '<language>en</language><script>Latn</script></bibdata><sections><clause id="source"><fmt-title>Source</fmt-title><p><xref target="target"/></p></clause><clause id="target">' \
            "<fmt-title>Target</fmt-title><fmt-xref-label><fmt-ladl-label-data local=\"#{label}\"/></fmt-xref-label></clause></sections></metanorma>"
      Metanorma::Standoc::Document::Root.from_xml(xml)
    end
    root = make_root.call("First label")
    renderer = Metanorma::Html::StandardRenderer.new
    expect(renderer.generate_body(root)).to include('href="#target">First label</a>')
    root.sections.clause.last.fmt_xref_label.first.fmt_ladl_label_data.local = "Edited label"
    expect(renderer.generate_body(root)).to include('href="#target">Edited label</a>')
    appended = Metanorma::Standoc::Document::Sections::ClauseSection.from_xml('<clause id="appended"><fmt-title>Appended</fmt-title><fmt-xref-label><fmt-ladl-label-data local="Appended label"/></fmt-xref-label></clause>')
    root.sections.clause << appended
    root.sections.clause.first.paragraphs.first.xref.first.target = "appended"
    expect(renderer.generate_full_document(root)).to include('href="#appended">Appended label</a>')
    other = make_root.call("Different root")
    expect(renderer.generate_body(other)).to include('href="#target">Different root</a>')
    renderer.document = root
    xref = Metanorma::Document::Components::Inline::XrefElement.new(target: "appended")
    expect(renderer.render_inline_element(xref)).to include(">Appended label</a>")
  end
end
