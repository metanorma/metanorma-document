# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe "HTML postprocessing replacements" do
  let(:renderer) { Metanorma::Html::StandardRenderer.new }
  let(:paragraph_class) { Metanorma::Document::Components::Paragraphs::ParagraphBlock }

  it "preserves input attributes without forcing enabled controls to disabled" do
    paragraph = paragraph_class.from_xml(<<~XML)
      <p><input id="x" name="field" type="text" value="A &amp; B" readonly="true" maxlength="10" minlength="2"/>
      <input type="checkbox" checked="true" disabled="true"/></p>
    XML
    html = renderer.render(paragraph)
    expect(html).to include('id="x"', 'name="field"', 'value="A &amp; B"', 'maxlength="10"', 'minlength="2"', 'readonly="true"')
    inputs = html.scan(/<input[^>]*>/)
    expect(inputs.first).not_to include("disabled=")
    expect(inputs.last).to include('disabled="true"', 'checked="true"')
  end

  it "renders mixed labels, select values and escaped textarea content from XML" do
    paragraph = paragraph_class.from_xml(<<~XML)
      <p>Before <label for="choose">Pick <strong>one</strong> now</label>
      <select id="choose" name="choice" value="b" multiple="true" size="2">
      <option value="a" disabled="true">Alpha</option><option value="b">B &amp; C</option></select>
      <textarea name="details" rows="3" cols="20" value="&lt;hello&gt;"/> After</p>
    XML
    html = renderer.render(paragraph)
    expect(html).to include('<label for="choose">Pick <strong>one</strong> now</label>')
    expect(html).to include('<select id="choose" name="choice" size="2" multiple="true">')
    expect(html).to include('<option value="a" disabled="true">Alpha</option>', '<option value="b" selected="true">B &amp; C</option>')
    expect(html).to include('<textarea name="details" rows="3" cols="20">&lt;hello&gt;</textarea>')
    expect(html.index("Before")).to be < html.index("Pick")
    expect(html.index("</textarea>")).to be < html.index("After")
  end

  it "preserves form metadata and ordered paragraph controls" do
    form = Metanorma::Standoc::Document::Blocks::Form.from_xml(<<~XML)
      <form id="survey" name="survey" class="application" action="/submit"><p><input name="answer" type="text" value="Yes"/></p></form>
    XML
    html = renderer.render(form)
    expect(html).to include('<form id="survey" name="survey" class="application" action="/submit">')
    expect(html).to include('name="answer"', 'value="Yes"', '</form>')
  end

  it "preserves controls in table cells and nested inline spans" do
    cell = Metanorma::Document::Components::Tables::TextTableCell.from_xml(<<~XML)
      <td><label for="s">Select</label><select id="s" value="a"><option value="a">A</option></select><span><textarea value="text"/></span></td>
    XML
    html = renderer.render_cell_content(cell)
    expect(html).to include('<label for="s">Select</label>', '<option value="a" selected="true">A</option>', '<textarea>text</textarea>')
  end

  it "gives repeated footnote references unique IDs and backlinks to each reference" do
    paragraph = paragraph_class.from_xml(<<~XML)
      <p>A<fn id="n1" target="same" reference="1"><p>Note</p></fn><fn id="n2" target="same" reference="1"><p>Note</p></fn></p>
    XML
    html = renderer.render(paragraph) + renderer.render_footnotes_section
    expect(html).to include('id="fnref-1"', 'id="fnref-1-2"')
    expect(html.scan('id="footnote-1"').size).to eq(1)
    expect(html).to include('href="#fnref-1"', 'href="#fnref-1-2"', 'href="#footnote-1"')
    expect(html.scan(/\bid="([^"]+)"/).flatten.uniq.size).to eq(html.scan(/\bid="([^"]+)"/).size)
  end

  it "keeps table footnotes local and links each marker to its table definition" do
    table = Metanorma::Document::Components::Tables::TableBlock.from_xml(<<~XML)
      <table id="t"><tbody><tr><td>A<fn reference="a"><p>Table note</p></fn></td></tr></tbody></table>
    XML
    first = renderer.render(table)
    second = renderer.render(table)
    expect(first).to include('href="#table-1-footnote-1"', 'id="table-1-footnote-1"', 'href="#table-1-fnref-1"')
    expect(second).to include('id="table-2-footnote-1"')
    expect(renderer.render_footnotes_section).to be_nil
  end

  it "resets collected footnotes between documents on a reused renderer" do
    document = Metanorma::Standoc::Document::Root.new(type: "presentation")
    renderer.render(paragraph_class.from_xml('<p><fn id="f" reference="1"><p>Old note</p></fn></p>'))
    output = renderer.generate_full_document(document)
    expect(output).not_to include('id="footnote-1"')
  end
end
