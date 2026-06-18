# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Factory do
  describe ".from_h" do
    it "raises ArgumentError for non-hash input" do
      -> {
        described_class.from_h("string")
      }.should raise_error(ArgumentError, /Hash/)
      -> {
        described_class.from_h(nil)
      }.should raise_error(ArgumentError, /Hash/)
    end

    it "raises ArgumentError when type key is missing" do
      -> {
        described_class.from_h({})
      }.should raise_error(ArgumentError, /'type'/)
    end

    it "creates Text from text hash" do
      node = described_class.from_h({ "type" => "text", "text" => "hello" })
      node.should be_a(Metanorma::Mirror::Model::Text)
      node.text.should eq("hello")
    end

    it "creates Text with marks" do
      node = described_class.from_h({
                                      "type" => "text",
                                      "text" => "bold",
                                      "marks" => [{ "type" => "strong" }],
                                    })
      node.marks.size.should eq(1)
      node.marks[0].type.should eq("strong")
    end

    it "creates SoftBreak" do
      node = described_class.from_h({ "type" => "soft_break" })
      node.should be_a(Metanorma::Mirror::Model::SoftBreak)
    end

    it "creates Container for nodes with content" do
      node = described_class.from_h({
                                      "type" => "clause",
                                      "attrs" => { "id" => "s1" },
                                      "content" => [{ "type" => "paragraph",
                                                      "content" => [] }],
                                    })
      node.should be_a(Metanorma::Mirror::Model::Container)
      node.type.should eq("clause")
      node.attrs["id"].should eq("s1")
      node.content.size.should eq(1)
      node.content[0].type.should eq("paragraph")
    end

    it "creates Leaf for nodes without content" do
      node = described_class.from_h({
                                      "type" => "image",
                                      "attrs" => { "src" => "img.png" },
                                    })
      node.should be_a(Metanorma::Mirror::Model::Leaf)
      node.type.should eq("image")
      node.attrs["src"].should eq("img.png")
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
      restored["type"].should eq("doc")
      restored["content"][0]["type"].should eq("paragraph")
      restored["content"][0]["content"][0]["text"].should eq("Hello")
      restored["content"][0]["content"][0]["marks"][0]["type"].should eq("strong")
    end

    it "handles string content mixed with nodes" do
      node = described_class.from_h({
                                      "type" => "paragraph",
                                      "content" => ["plain text",
                                                    { "type" => "text",
                                                      "text" => "styled" }],
                                    })
      node.content.size.should eq(2)
      node.content[0].should eq("plain text")
      node.content[1].should be_a(Metanorma::Mirror::Model::Text)
    end
  end
end
