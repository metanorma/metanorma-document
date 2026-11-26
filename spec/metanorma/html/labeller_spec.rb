# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/labeller"

RSpec.describe Metanorma::Html::Labeller do
  let(:profile) do
    File.expand_path("../../fixtures/ladl/label_style.lml", __dir__)
  end

  let(:components) { Metanorma::Document::Components }

  # Annex-named stub section: the ladl adapter maps the class-name
  # suffix to the annex type (the flavor annex model pattern).
  annex_section_class = Class.new do
    attr_reader :anchor, :children

    def initialize(anchor, children = [])
      @anchor = anchor
      @children = children
    end
  end
  Object.const_set("LabellerSpecAnnexSection", annex_section_class)

  # Document root stub: the adapter maps the exact class name
  # DocumentRoot to the document type (opening the DocumentContext).
  root_class = Class.new do
    attr_reader :children

    def initialize(children = [])
      @children = children
    end
  end
  Object.const_set("DocumentRoot", root_class)

  let(:sec1) do
    components::Sections::HierarchicalSection.new(
      anchor: "sec1",
      subsections: [
        components::Sections::HierarchicalSection.new(anchor: "sec1a"),
      ],
    )
  end
  let(:annex) do
    LabellerSpecAnnexSection.new("ax")
  end
  let(:root) do
    DocumentRoot.new([sec1, annex])
  end

  subject(:labeller) { described_class.new(profile, root: root) }

  it "labels clauses hierarchically" do
    expect(labeller.local_for(sec1)).to eq("1")
    expect(labeller.local_for(sec1.subsections.first)).to eq("1.1")
  end

  it "labels annexes through the annex context" do
    expect(labeller.local_for(annex)).to eq("Annex A")
  end

  it "exposes global cross-reference labels" do
    expect(labeller.global_for(sec1)).to eq("Clause 1")
  end

  it "returns nil for unknown elements" do
    expect(labeller.local_for(components::Sections::BasicSection.new)).to be_nil
  end
end

RSpec.describe Metanorma::Html::BaseRenderer do
  let(:profile) do
    File.expand_path("../../fixtures/ladl/label_style.lml", __dir__)
  end

  def titled_section(anchor, title_text)
    components = Metanorma::Document::Components
    components::Sections::HierarchicalSection.new(
      anchor: anchor,
      title: components::TextElements::TextElement.new(content: title_text),
    )
  end

  subject(:renderer) { described_class.new }

  it "prefixes unnumbered titles with the labeller label" do
    section = titled_section("sec1", "Normative references")
    renderer.labeller = Metanorma::Html::Labeller.new(
      profile, root: DocumentRoot.new([section])
    )
    expect(renderer.prefix_labeller_label(section, "Normative references"))
      .to eq("1 Normative references")
  end

  it "does not double-prefix already-numbered titles" do
    section = titled_section("sec1", "1 Normative references")
    renderer.labeller = Metanorma::Html::Labeller.new(
      profile, root: DocumentRoot.new([section])
    )
    expect(renderer.prefix_labeller_label(section, "1 Normative references"))
      .to eq("1 Normative references")
  end

  it "leaves text untouched when no labeller is configured" do
    section = titled_section("sec1", "Normative references")
    expect(renderer.prefix_labeller_label(section, "Normative references"))
      .to eq("Normative references")
  end
end
