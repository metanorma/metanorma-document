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
    Metanorma::Mirror::Model::Factory.from_h(node_hash)
  end

  describe ".serialize" do
    it "produces valid JSON from a hash" do
      json = described_class.serialize(node_hash)
      parsed = JSON.parse(json)
      parsed["type"].should eq("paragraph")
    end

    it "produces valid JSON from a model object" do
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
    it "reconstructs the model object tree" do
      json = described_class.serialize(node)
      restored = described_class.deserialize(json)
      restored.should be_a(Metanorma::Mirror::Model::Container)
      restored.type.should eq("paragraph")
      restored.attrs["id"].should eq("p1")
      restored.content.first.should be_a(Metanorma::Mirror::Model::Text)
      restored.content.first.text.should eq("hello")
      restored.content.first.marks.first.type.should eq("emphasis")
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
                    "content" => [{ "type" => "text", "text" => "Scope content" }],
                  },
                ],
              },
            ],
          },
        ],
      }

      json = described_class.serialize(doc_hash)
      restored = described_class.deserialize(json)

      restored.type.should eq("doc")
      restored.attrs["title"].should eq("Test")
      restored.content.size.should eq(2)
      restored.content.first.type.should eq("preface")
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
    Metanorma::Mirror::Model::Factory.from_h(node_hash)
  end

  describe ".serialize" do
    it "produces valid YAML from a hash" do
      yaml = described_class.serialize(node_hash)
      parsed = YAML.safe_load(yaml)
      parsed["type"].should eq("paragraph")
    end

    it "produces valid YAML from a model object" do
      yaml = described_class.serialize(node)
      parsed = YAML.safe_load(yaml)
      parsed["type"].should eq("paragraph")
    end
  end

  describe ".deserialize" do
    it "reconstructs the model object tree" do
      yaml = described_class.serialize(node)
      restored = described_class.deserialize(yaml)
      restored.should be_a(Metanorma::Mirror::Model::Container)
      restored.type.should eq("paragraph")
      restored.attrs["id"].should eq("p1")
      restored.content.first.should be_a(Metanorma::Mirror::Model::Text)
      restored.content.first.text.should eq("hello")
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
      restored.type.should eq("doc")
      restored.attrs["flavor"].should eq("iso")
    end
  end
end
