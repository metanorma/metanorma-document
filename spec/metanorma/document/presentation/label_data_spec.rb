# frozen_string_literal: true

require "spec_helper"
require "yaml"

module LabelDataSpecSupport
  Holder = Struct.new(:nodes)
  Label = Struct.new(:local, :global, :value, :direction, :global_direction, :labeller)
end

RSpec.describe Metanorma::Document::Presentation::LabelData do
  let(:presentation) { Metanorma::Document::Presentation }
  let(:components) { Metanorma::Document::Components }
  let(:expected) { YAML.load_file(File.expand_path("../../../fixtures/presentation/ladl_labels.yml", __dir__)) }
  let(:classes) do
    c = components
    { "clause" => c::Sections::BasicSection, "subclause" => c::Sections::BasicSection,
      "annex" => c::Sections::BasicSection, "annex_clause" => c::Sections::BasicSection,
      "figure" => c::AncillaryBlocks::FigureBlock, "annex_figure" => c::AncillaryBlocks::FigureBlock,
      "subfigure" => c::AncillaryBlocks::Subfigure,
      "table" => c::Tables::TableBlock, "annex_table" => c::Tables::TableBlock,
      "note" => c::Blocks::NoteBlock, "example" => c::AncillaryBlocks::ExampleBlock,
      "formula" => c::AncillaryBlocks::FormulaBlock, "annex_formula" => c::AncillaryBlocks::FormulaBlock,
      "list" => c::Lists::OrderedList, "annex_list" => c::Lists::OrderedList,
      "unordered" => c::Lists::ListItem, "level1" => c::Lists::ListItem, "level2" => c::Lists::ListItem,
      "level3" => c::Lists::ListItem, "level4" => c::Lists::ListItem }
  end
  # A plain holder: the engine copies it, the source finds nodes in the copy.
  let(:model) { LabelDataSpecSupport::Holder.new(classes.map { |id, klass| klass.new(id: id) }) }
  let(:source) do
    labels = expected.to_h { |row| [row["id"], LabelDataSpecSupport::Label.new(*row.values_at("local", "global", "value", "direction", "global_direction", "labeller"))] }
    ->(m) { m.nodes.map { |node| [node, labels.fetch(node.id)] } }
  end
  let(:engine) do
    presentation::Engine.new(profile: presentation::Profile.new(name: "labels", rules: [described_class.new(source: source)]))
  end

  def data_of(node)
    typed = node.class.attributes[:fmt_xref_label]
    if typed&.collection?
      Array(node.fmt_xref_label).find { |i| i.container == "ladl" }&.fmt_ladl_label_data
    else
      node.fmt_ladl_label_data
    end
  end

  it "fixture covers 20 distinct labellers" do
    expect(expected.size).to eq(20)
    expect(expected.map { |r| r["labeller"] }.uniq.size).to eq(20)
  end

  it "persists all fields for all 20 labellers, equal to the LADL fixture" do
    out = engine.call(model)
    actual = out.nodes.map do |node|
      d = data_of(node)
      { "id" => node.id, "local" => d.local, "global" => d.global, "value" => d.value,
        "direction" => d.direction, "global_direction" => d.global_direction, "labeller" => d.labeller }
    end
    want = expected.map { |r| r.slice("id", "local", "global", "value", "direction", "global_direction", "labeller") }
    expect(actual.sort_by { |r| r["id"] }).to eq(want.sort_by { |r| r["id"] })
  end

  it "does not modify the input document" do
    engine.call(model)
    expect(model.nodes.map { |n| data_of(n) }).to all(be_nil)
  end

  it "survives an XML roundtrip of each node" do
    Lutaml::Model::Config.xml_adapter_type = :nokogiri
    out = engine.call(model)
    out.nodes.each do |node|
      again = node.class.from_xml(node.to_xml)
      fields = %i[local global value direction global_direction labeller]
      expect(fields.map { |f| data_of(again).public_send(f) }).to eq(fields.map { |f| data_of(node).public_send(f) }), node.id
    end
  end

  it "is idempotent" do
    once = engine.call(model)
    twice = engine.call(once)
    expect(twice.nodes.map(&:to_xml)).to eq(once.nodes.map(&:to_xml))
  end

  it "clears a node when the source returns no label" do
    out = engine.call(model)
    clear = presentation::Engine.new(profile: presentation::Profile.new(
      rules: [described_class.new(source: ->(m) { m.nodes.map { |n| [n, nil] } })],
    ))
    expect(clear.call(out).nodes.map { |n| data_of(n) }).to all(be_nil)
  end

  it "fails loud on a node that cannot hold label data" do
    bad = described_class.new(source: ->(_m) { [["x", LabelDataSpecSupport::Label.new("1")]] })
    expect { bad.call(model) }.to raise_error(ArgumentError, /cannot hold/)
  end
end
