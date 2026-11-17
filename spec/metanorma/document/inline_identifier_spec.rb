# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Inline::IdentifierElement do
  it "parses an inline identifier with its text and id" do
    xml = '<identifier id="i1">/req/roles/register-owner</identifier>'
    ident = described_class.from_xml(xml)

    expect(ident.id).to eq("i1")
    expect(ident.text).to eq(["/req/roles/register-owner"])
  end
end

RSpec.describe Metanorma::Document::Components::Paragraphs::ParagraphBlock do
  it "binds a semantic identifier and its fmt-identifier mirror" do
    xml = '<p id="p1">satisfies X, <identifier id="i1">/req/a</identifier>' \
          '<fmt-identifier><tt><semx element="identifier" source="i1">/req/a</semx></tt>' \
          "</fmt-identifier>.</p>"
    p = described_class.from_xml(xml)

    expect(Array(p.identifier).size).to eq(1)
    expect(Array(p.identifier).first.text).to eq(["/req/a"])
    expect(Array(p.fmt_identifier).size).to eq(1)
    expect(p.text).to eq(["satisfies X, ", "."])
  end

  it "binds a trailing example nested in the paragraph" do
    xml = '<p id="p1">text<example id="e1"><p id="p2">example body</p></example></p>'
    p = described_class.from_xml(xml)

    examples = Array(p.example)
    expect(examples.size).to eq(1)
    texts = Array(examples.first.paragraphs).flat_map { |x| Array(x.text) }
    expect(texts.join(" ")).to include("example body")
  end
end

RSpec.describe Metanorma::Document::Components::Tables::TextTableCell do
  it "binds identifier and nested provision models in cells" do
    xml = '<td id="td1"><identifier id="i1">/req/x</identifier>' \
          "<example id=\"e1\"><p id=\"p1\">cell example</p></example></td>"
    cell = Metanorma::Document::Components::Tables::TextTableCell.from_xml(xml)

    expect(Array(cell.identifier).first.text).to eq(["/req/x"])
    expect(Array(cell.example).size).to eq(1)
  end

  it "binds a nested requirement tree" do
    xml = '<td id="td1"><requirement id="r1" anchor="r-1">' \
          "<example id=\"e1\"><p id=\"p1\">nested example</p></example>" \
          "</requirement></td>"
    cell = Metanorma::Document::Components::Tables::TextTableCell.from_xml(xml)

    reqs = Array(cell.requirement)
    expect(reqs.size).to eq(1)
    expect(Array(reqs.first.example).size).to eq(1)
  end
end

RSpec.describe Metanorma::Document::Components::Blocks::RequirementComponent do
  it "parses a guidance component with class and content" do
    xml = '<component class="guidance" id="c1"><p id="p1">guidance text</p></component>'
    comp = described_class.from_xml(xml)

    expect(comp.class_attr).to eq("guidance")
    expect(Array(comp.p).first.text).to eq(["guidance text"])
  end
end

RSpec.describe Metanorma::Document::Components::Blocks::RequirementModel do
  it "binds its components" do
    xml = '<requirement id="r1" anchor="r-1">' \
          '<component class="guidance"><p id="p1">g</p></component></requirement>'
    req = described_class.from_xml(xml)

    comps = Array(req.component)
    expect(comps.size).to eq(1)
    expect(comps.first.class_attr).to eq("guidance")
  end
end

RSpec.describe Metanorma::Document::Components::Inline::SemxElement do
  it "binds example and note children" do
    xml = "<semx element=\"p\" source=\"p1\">" \
          "<p id=\"p1\">intro</p>" \
          "<example id=\"e1\"><p id=\"p2\">ex</p></example>" \
          "<note id=\"n1\"><p id=\"p3\">nt</p></note></semx>"
    semx = described_class.from_xml(xml)

    expect(Array(semx.example_child).size).to eq(1)
    expect(Array(semx.note_child).size).to eq(1)
  end
end
