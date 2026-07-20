# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Rewriter do
  let(:forward) { Metanorma::Mirror::Transformer.new }
  let(:reverse) { described_class.new }

  let(:complex_doc_hash) do
    {
      "type" => "doc",
      "attrs" => { "flavor" => "iso", "title" => "Test Doc" },
      "content" => [
        {
          "type" => "preface",
          "content" => [
            {
              "type" => "content_section",
              "attrs" => { "title" => "Foreword" },
              "content" => [
                {
                  "type" => "paragraph",
                  "content" => [{ "type" => "text",
                                  "text" => "Foreword text" }],
                },
              ],
            },
          ],
        },
        {
          "type" => "sections",
          "content" => [
            {
              "type" => "clause",
              "attrs" => { "id" => "s1", "title" => "Scope",
                           "number" => "1" },
              "content" => [
                {
                  "type" => "paragraph",
                  "attrs" => { "id" => "p1" },
                  "content" => [
                    { "type" => "text", "text" => "Hello " },
                    {
                      "type" => "text",
                      "text" => "world",
                      "marks" => [{ "type" => "emphasis" }],
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
    }
  end

  let(:complex_doc) do
    Metanorma::Mirror::Model::Factory.from_h(complex_doc_hash)
  end

  describe "mirror model round-trip through serialization" do
    it "round-trips a document tree through JSON" do
      json = Metanorma::Mirror::Serialization::JsonSerializer.serialize(complex_doc)
      restored = Metanorma::Mirror::Serialization::JsonSerializer.deserialize(json)

      expect(restored).to be_a(Metanorma::Mirror::Model::Container)
      expect(restored.type).to eq("doc")
      expect(restored.attrs["flavor"]).to eq("iso")
      expect(restored.content.size).to eq(2)

      preface = restored.content[0]
      expect(preface.type).to eq("preface")

      sections = restored.content[1]
      clause = sections.content[0]
      expect(clause.attrs["title"]).to eq("Scope")
      expect(clause.attrs["number"]).to eq("1")

      para = clause.content[0]
      expect(para.content[0]).to be_a(Metanorma::Mirror::Model::Text)
      expect(para.content[0].text).to eq("Hello ")
      expect(para.content[1].text).to eq("world")
      expect(para.content[1].marks.first.type).to eq("emphasis")
    end

    it "round-trips through JSON with strong marks" do
      doc_hash = {
        "type" => "doc",
        "attrs" => { "flavor" => "iso" },
        "content" => [
          {
            "type" => "sections",
            "content" => [
              {
                "type" => "clause",
                "attrs" => { "id" => "s1" },
                "content" => [
                  {
                    "type" => "paragraph",
                    "content" => [
                      {
                        "type" => "text",
                        "text" => "bold text",
                        "marks" => [{ "type" => "strong" }],
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      }
      doc = Metanorma::Mirror::Model::Factory.from_h(doc_hash)

      json = Metanorma::Mirror::Serialization::JsonSerializer.serialize(doc)
      restored = Metanorma::Mirror::Serialization::JsonSerializer.deserialize(json)

      expect(restored.attrs["flavor"]).to eq("iso")
      clause = restored.content[0].content[0]
      expect(clause.type).to eq("clause")
      expect(clause.content[0].content[0].marks.first.type).to eq("strong")
    end

    it "round-trips through YAML serialization" do
      doc_hash = {
        "type" => "doc",
        "content" => [
          { "type" => "bibliography", "content" => [] },
        ],
      }
      doc = Metanorma::Mirror::Model::Factory.from_h(doc_hash)

      yaml = Metanorma::Mirror::Serialization::YamlSerializer.serialize(doc)
      restored = Metanorma::Mirror::Serialization::YamlSerializer.deserialize(yaml)

      expect(restored.type).to eq("doc")
      expect(restored.content[0].type).to eq("bibliography")
    end
  end
end
