# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Serialization::JsonSerializer do
  let(:node_hash) do
    {
      "type" => "paragraph",
      "attrs" => { "id" => "p1" },
      "content" => [
        { "type" => "text", "text" => "hello",
          "marks" => [{ "type" => "emphasis" }] },
      ],
    }
  end

  let(:node) do
    Metanorma::Mirror::Model::Factory.from_hash(node_hash)
  end

  describe ".serialize" do
    it "produces valid JSON from a hash" do
      json = described_class.serialize(node_hash)
      parsed = JSON.parse(json)
      expect(parsed["type"]).to eq("paragraph")
    end

    it "produces valid JSON from a model object" do
      json = described_class.serialize(node)
      parsed = JSON.parse(json)
      expect(parsed["type"]).to eq("paragraph")
    end
  end

  describe ".serialize_pretty" do
    it "produces pretty-printed JSON" do
      json = described_class.serialize_pretty(node)
      expect(json).to include("\n")
      parsed = JSON.parse(json)
      expect(parsed["type"]).to eq("paragraph")
    end
  end

  describe ".deserialize" do
    it "reconstructs the model object tree" do
      json = described_class.serialize(node)
      restored = described_class.deserialize(json)
      expect(restored).to be_a(Metanorma::Mirror::Model::Container)
      expect(restored.type).to eq("paragraph")
      expect(restored.attrs["id"]).to eq("p1")
      expect(restored.content.first).to be_a(Metanorma::Mirror::Model::Text)
      expect(restored.content.first.text).to eq("hello")
      expect(restored.content.first.marks.first.type).to eq("emphasis")
    end
  end

  describe "round-trip" do
    it "preserves data through serialize -> deserialize" do
      doc_hash = {
        "type" => "doc",
        "attrs" => { "title" => "Test", "flavor" => "iso" },
        "content" => [
          {
            "type" => "preface",
            "content" => [
              {
                "type" => "paragraph",
                "content" => [{ "type" => "text", "text" => "Foreword text" }],
              },
            ],
          },
          {
            "type" => "sections",
            "content" => [
              {
                "type" => "clause",
                "attrs" => { "id" => "s1", "title" => "Scope" },
                "content" => [
                  {
                    "type" => "paragraph",
                    "content" => [{ "type" => "text",
                                    "text" => "Scope content" }],
                  },
                ],
              },
            ],
          },
        ],
      }

      json = described_class.serialize(doc_hash)
      restored = described_class.deserialize(json)

      expect(restored.type).to eq("doc")
      expect(restored.attrs["title"]).to eq("Test")
      expect(restored.content.size).to eq(2)
      expect(restored.content.first.type).to eq("preface")
    end
  end
end

RSpec.describe Metanorma::Mirror::Serialization::YamlSerializer do
  let(:node_hash) do
    {
      "type" => "paragraph",
      "attrs" => { "id" => "p1" },
      "content" => [{ "type" => "text", "text" => "hello" }],
    }
  end

  let(:node) do
    Metanorma::Mirror::Model::Factory.from_hash(node_hash)
  end

  describe ".serialize" do
    it "produces valid YAML from a hash" do
      yaml = described_class.serialize(node_hash)
      parsed = YAML.safe_load(yaml)
      expect(parsed["type"]).to eq("paragraph")
    end

    it "produces valid YAML from a model object" do
      yaml = described_class.serialize(node)
      parsed = YAML.safe_load(yaml)
      expect(parsed["type"]).to eq("paragraph")
    end
  end

  describe ".deserialize" do
    it "reconstructs the model object tree" do
      yaml = described_class.serialize(node)
      restored = described_class.deserialize(yaml)
      expect(restored).to be_a(Metanorma::Mirror::Model::Container)
      expect(restored.type).to eq("paragraph")
      expect(restored.attrs["id"]).to eq("p1")
      expect(restored.content.first).to be_a(Metanorma::Mirror::Model::Text)
      expect(restored.content.first.text).to eq("hello")
    end
  end

  describe "round-trip" do
    it "preserves data through serialize -> deserialize" do
      doc_hash = {
        "type" => "doc",
        "attrs" => { "flavor" => "iso" },
        "content" => [
          { "type" => "sections", "content" => [] },
        ],
      }

      yaml = described_class.serialize(doc_hash)
      restored = described_class.deserialize(yaml)
      expect(restored.type).to eq("doc")
      expect(restored.attrs["flavor"]).to eq("iso")
    end
  end
end
