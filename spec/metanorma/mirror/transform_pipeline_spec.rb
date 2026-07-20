# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso_document"

RSpec.describe "Mirror forward transform pipeline" do
  let(:xml_path) do
    File.expand_path("../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) { File.read(xml_path) }

  describe "full pipeline with real ISO document" do
    it "parses XML and produces a mirror Container model" do
      doc = Metanorma::IsoDocument::Root.from_xml(xml)
      transformer = Metanorma::Mirror::Transformer.new
      result = transformer.from_metanorma(doc)

      expect(result).to be_a(Metanorma::Mirror::Model::Container)
      expect(result.type).to eq("doc")
      expect(result.content).not_to be_empty
    end

    it "produces serializable output" do
      doc = Metanorma::IsoDocument::Root.from_xml(xml)
      transformer = Metanorma::Mirror::Transformer.new
      result = transformer.from_metanorma(doc)

      json = Metanorma::Mirror::Serialization::JsonSerializer.serialize(result)
      parsed = Metanorma::Mirror::Serialization::JsonSerializer.deserialize(json)
      expect(parsed.type).to eq("doc")
      expect(parsed.content).to be_an(Array)
    end

    it "round-trips through JSON serialization" do
      doc = Metanorma::IsoDocument::Root.from_xml(xml)
      transformer = Metanorma::Mirror::Transformer.new
      result = transformer.from_metanorma(doc)

      json = Metanorma::Mirror::Serialization::JsonSerializer.serialize(result)
      restored = Metanorma::Mirror::Serialization::JsonSerializer.deserialize(json)

      expect(restored.type).to eq("doc")
      expect(restored.content.size).to eq(result.content.size)
    end
  end

  describe "section structure" do
    let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
    let(:mirror) { Metanorma::Mirror::Transformer.new.from_metanorma(doc) }

    it "contains preface and sections" do
      types = mirror.content.map(&:type)
      expect(types).to include("preface")
      expect(types).to include("sections")
    end

    it "preface contains content sections" do
      preface = mirror.content.find { |n| n.type == "preface" }
      expect(preface).to be_a(Metanorma::Mirror::Model::Container)
      expect(preface.type).to eq("preface")
      expect(preface.content).not_to be_empty
    end

    it "sections contain clauses" do
      sections = mirror.content.find { |n| n.type == "sections" }
      expect(sections).to be_a(Metanorma::Mirror::Model::Container)
      expect(sections.type).to eq("sections")
      clauses = sections.content.select { |n| n.type == "clause" }
      expect(clauses).not_to be_empty
    end
  end

  describe "inline content" do
    let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
    let(:mirror) { Metanorma::Mirror::Transformer.new.from_metanorma(doc) }

    it "paragraphs contain text nodes" do
      paragraphs = []
      mirror.content.each do |node|
        collect_nodes_of_type(paragraphs, node, "paragraph")
      end
      expect(paragraphs).not_to be_empty

      first_para = paragraphs.first
      text_nodes = first_para.content.grep(Metanorma::Mirror::Model::Text)
      expect(text_nodes).not_to be_empty
    end

    it "preserves cross-reference marks" do
      marks = collect_all_marks(mirror)
      xrefs = marks.select { |m| m.type == "xref" }
      expect(xrefs).not_to be_empty
      xrefs.each { |x| expect(x.attrs["target"]).to be_a(String) }
    end

    it "preserves eref marks with citation data" do
      marks = collect_all_marks(mirror)
      erefs = marks.select { |m| m.type == "eref" }
      expect(erefs).not_to be_empty
    end

    it "preserves footnote marks" do
      marks = collect_all_marks(mirror)
      footnotes = marks.select { |m| m.type == "footnote" }
      expect(footnotes).not_to be_empty
    end
  end

  describe "ID strategy" do
    it "Preserve strategy keeps original IDs" do
      doc = Metanorma::IsoDocument::Root.from_xml(xml)
      strategy = Metanorma::Mirror::IdStrategy::Preserve.new
      transformer = Metanorma::Mirror::Transformer.new(id_strategy: strategy)
      result = transformer.from_metanorma(doc)

      clauses = []
      result.content.each { |n| collect_nodes_of_type(clauses, n, "clause") }
      clauses.each do |clause|
        next unless clause.attrs["id"]

        expect(clause.attrs["id"]).not_to be_nil
      end
    end

    it "Positional strategy assigns positional IDs" do
      doc = Metanorma::IsoDocument::Root.from_xml(xml)
      strategy = Metanorma::Mirror::IdStrategy::Positional.new
      transformer = Metanorma::Mirror::Transformer.new(id_strategy: strategy)
      result = transformer.from_metanorma(doc)

      expect(result).to be_a(Metanorma::Mirror::Model::Container)
      expect(result.type).to eq("doc")
    end
  end

  describe "block types" do
    let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
    let(:mirror) { Metanorma::Mirror::Transformer.new.from_metanorma(doc) }

    it "produces note nodes" do
      notes = []
      mirror.content.each { |n| collect_nodes_of_type(notes, n, "note") }
      notes.each do |note|
        expect(note.type).to eq("note")
        expect(note.content).not_to be_empty
      end
    end

    it "produces ordered and bullet lists" do
      lists = []
      mirror.content.each do |n|
        collect_nodes_of_type(lists, n, "ordered_list")
        collect_nodes_of_type(lists, n, "bullet_list")
      end
      lists.each do |list|
        expect(list.content).not_to be_empty
      end
    end

    it "produces table nodes with proper structure" do
      tables = []
      mirror.content.each { |n| collect_nodes_of_type(tables, n, "table") }
      tables.each do |table|
        expect(table.type).to eq("table")
        body = (table.content || []).find { |c| c.type == "table_body" }
        if body
          expect(body.type).to eq("table_body")
          body.content.each do |row|
            expect(row.type).to eq("table_row")
          end
        end
      end
    end
  end

  private

  def collect_nodes_of_type(collection, node, type)
    return if node.is_a?(String)

    collection << node if node.type == type
    children = node.is_a?(Metanorma::Mirror::Model::Container) ? node.content : []
    children.each { |child| collect_nodes_of_type(collection, child, type) }
  end

  def collect_all_marks(node)
    marks = []
    return marks if node.is_a?(String)

    if node.is_a?(Metanorma::Mirror::Model::Text)
      marks.concat(Array(node.marks))
    end
    children = node.is_a?(Metanorma::Mirror::Model::Container) ? node.content : []
    children.each { |child| marks.concat(collect_all_marks(child)) }
    marks
  end
end
