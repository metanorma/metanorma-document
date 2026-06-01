# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Serialization::JsonSerializer do
  let(:node) do
    text = Metanorma::Mirror::Node::Text.new(text: "hello", marks: [Metanorma::Mirror::Mark::Emphasis.new])
    Metanorma::Mirror::Node::Paragraph.new(attrs: { id: "p1" }, content: [text])
  end

  describe ".serialize" do
    it "produces valid JSON" do
      json = described_class.serialize(node)
      parsed = JSON.parse(json)
      parsed["type"].should eq("paragraph")
    end
  end

  describe ".serialize_pretty" do
    it "produces pretty-printed JSON" do
      json = described_class.serialize_pretty(node)
      json.should include("\n")
      parsed = JSON.parse(json)
      parsed["type"].should eq("paragraph")
    end
  end

  describe ".deserialize" do
    it "reconstructs the node tree" do
      json = described_class.serialize(node)
      restored = described_class.deserialize(json)
      restored.should be_a(Metanorma::Mirror::Node::Paragraph)
      restored.attrs[:id].should eq("p1")
      restored.content.first.text.should eq("hello")
      restored.content.first.marks.first.type.should eq("emphasis")
    end
  end

  describe "round-trip" do
    it "preserves data through serialize → deserialize" do
      doc = Metanorma::Mirror::Node::Document.new(
        attrs: { title: "Test", flavor: "iso" },
        content: [
          Metanorma::Mirror::Node::Preface.new(content: [
                                                 Metanorma::Mirror::Node::Paragraph.new(content: [
                                                                                          Metanorma::Mirror::Node::Text.new(text: "Foreword text"),
                                                                                        ]),
                                               ]),
          Metanorma::Mirror::Node::Sections.new(content: [
                                                  Metanorma::Mirror::Node::Clause.new(attrs: { id: "s1", title: "Scope" }, content: [
                                                                                        Metanorma::Mirror::Node::Paragraph.new(content: [
                                                                                                                                 Metanorma::Mirror::Node::Text.new(text: "Scope content"),
                                                                                                                               ]),
                                                                                      ]),
                                                ]),
        ],
      )

      json = described_class.serialize(doc)
      restored = described_class.deserialize(json)

      restored.should be_a(Metanorma::Mirror::Node::Document)
      restored.attrs[:title].should eq("Test")
      restored.content.size.should eq(2)
      restored.content.first.should be_a(Metanorma::Mirror::Node::Preface)
    end
  end
end

RSpec.describe Metanorma::Mirror::Serialization::YamlSerializer do
  let(:node) do
    Metanorma::Mirror::Node::Paragraph.new(
      attrs: { id: "p1" },
      content: [Metanorma::Mirror::Node::Text.new(text: "hello")],
    )
  end

  describe ".serialize" do
    it "produces valid YAML" do
      yaml = described_class.serialize(node)
      parsed = YAML.safe_load(yaml)
      parsed["type"].should eq("paragraph")
    end
  end

  describe ".deserialize" do
    it "reconstructs the node tree" do
      yaml = described_class.serialize(node)
      restored = described_class.deserialize(yaml)
      restored.should be_a(Metanorma::Mirror::Node::Paragraph)
      restored.attrs[:id].should eq("p1")
      restored.content.first.text.should eq("hello")
    end
  end

  describe "round-trip" do
    it "preserves data through serialize → deserialize" do
      doc = Metanorma::Mirror::Node::Document.new(
        attrs: { flavor: "iso" },
        content: [
          Metanorma::Mirror::Node::Sections.new(content: []),
        ],
      )

      yaml = described_class.serialize(doc)
      restored = described_class.deserialize(yaml)
      restored.should be_a(Metanorma::Mirror::Node::Document)
      restored.attrs[:flavor].should eq("iso")
    end
  end
end
