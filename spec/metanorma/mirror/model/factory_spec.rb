# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Factory do
  describe ".from_h" do
    it "raises ArgumentError for non-hash input" do
      expect do
        described_class.from_h("string")
      end.to raise_error(ArgumentError, /Hash/)
      expect do
        described_class.from_h(nil)
      end.to raise_error(ArgumentError, /Hash/)
    end

    it "raises ArgumentError when type key is missing" do
      expect do
        described_class.from_h({})
      end.to raise_error(ArgumentError, /'type'/)
    end

    it "creates Text from text hash" do
      node = described_class.from_h({ "type" => "text", "text" => "hello" })
      expect(node).to be_a(Metanorma::Mirror::Model::Text)
      expect(node.text).to eq("hello")
    end

    it "creates Text with marks" do
      node = described_class.from_h({
                                      "type" => "text",
                                      "text" => "bold",
                                      "marks" => [{ "type" => "strong" }],
                                    })
      expect(node.marks.size).to eq(1)
      expect(node.marks[0].type).to eq("strong")
    end

    it "creates SoftBreak" do
      node = described_class.from_h({ "type" => "soft_break" })
      expect(node).to be_a(Metanorma::Mirror::Model::SoftBreak)
    end

    it "creates Container for nodes with content" do
      node = described_class.from_h({
                                      "type" => "clause",
                                      "attrs" => { "id" => "s1" },
                                      "content" => [{ "type" => "paragraph",
                                                      "content" => [] }],
                                    })
      expect(node).to be_a(Metanorma::Mirror::Model::Container)
      expect(node.type).to eq("clause")
      expect(node.attrs["id"]).to eq("s1")
      expect(node.content.size).to eq(1)
      expect(node.content[0].type).to eq("paragraph")
    end

    it "creates Leaf for nodes without content" do
      node = described_class.from_h({
                                      "type" => "image",
                                      "attrs" => { "src" => "img.png" },
                                    })
      expect(node).to be_a(Metanorma::Mirror::Model::Leaf)
      expect(node.type).to eq("image")
      expect(node.attrs["src"]).to eq("img.png")
    end

    it "round-trips a full document" do
      hash = {
        "type" => "doc",
        "attrs" => { "flavor" => "iso" },
        "content" => [
          { "type" => "paragraph", "content" => [
            { "type" => "text", "text" => "Hello", "marks" => [{ "type" => "strong" }] },
          ] },
        ],
      }
      model = described_class.from_h(hash)
      restored = model.to_h
      expect(restored["type"]).to eq("doc")
      expect(restored["content"][0]["type"]).to eq("paragraph")
      expect(restored["content"][0]["content"][0]["text"]).to eq("Hello")
      expect(restored["content"][0]["content"][0]["marks"][0]["type"]).to eq("strong")
    end

    it "handles string content mixed with nodes" do
      node = described_class.from_h({
                                      "type" => "paragraph",
                                      "content" => ["plain text",
                                                    { "type" => "text",
                                                      "text" => "styled" }],
                                    })
      expect(node.content.size).to eq(2)
      expect(node.content[0]).to eq("plain text")
      expect(node.content[1]).to be_a(Metanorma::Mirror::Model::Text)
    end
  end
end
