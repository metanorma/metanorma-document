# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/labeller"

RSpec.describe Metanorma::Html::Labeller do
  let(:profile) do
    File.expand_path("../../fixtures/ladl/label_style.lml", __dir__)
  end

  let(:components) { Metanorma::Document::Components }
  let(:standoc_sections) { Metanorma::Standoc::Document::Sections }

  let(:sec1) do
    components::Sections::HierarchicalSection.new(
      id: "sec1",
      subsections: [
        components::Sections::HierarchicalSection.new(id: "sec1a"),
      ],
    )
  end
  let(:annex) do
    standoc_sections::AnnexSection.new(id: "ax")
  end
  # The standoc document root: the Sections container holds clauses,
  # the annex collection holds annexes.
  let(:root) do
    standoc_root = Metanorma::Standoc::Document::Root
    standoc_root.new(
      sections: standoc_sections::Sections.new(clause: [sec1]),
      annex: [annex],
    )
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

  let(:components) { Metanorma::Document::Components }

  def titled_section(id, title_text)
    components::Sections::HierarchicalSection.new(
      id: id,
      title: components::TextElements::TextElement.new(content: title_text),
    )
  end

  subject(:renderer) { described_class.new }

  it "prefixes unnumbered titles with the labeller label" do
    section = titled_section("sec1", "Normative references")
    root = Metanorma::Standoc::Document::Sections::Sections.new(clause: [section])
    renderer.labeller = Metanorma::Html::Labeller.new(profile, root: root)
    expect(renderer.prefix_labeller_label(section, "Normative references"))
      .to eq("1 Normative references")
  end

  it "does not double-prefix already-numbered titles" do
    section = titled_section("sec1", "1 Normative references")
    root = Metanorma::Standoc::Document::Sections::Sections.new(clause: [section])
    renderer.labeller = Metanorma::Html::Labeller.new(profile, root: root)
    expect(renderer.prefix_labeller_label(section, "1 Normative references"))
      .to eq("1 Normative references")
  end

  it "leaves text untouched when no labeller is configured" do
    section = titled_section("sec1", "Normative references")
    expect(renderer.prefix_labeller_label(section, "Normative references"))
      .to eq("Normative references")
  end
end
