# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Node do
  describe "auto-registration" do
    expected_types = %w[
      doc preface sections bibliography clause annex content_section abstract
      foreword introduction acknowledgements terms definitions references
      paragraph note admonition example figure image sourcecode formula
      table table_head table_body table_foot table_row table_cell quote review
      floating_title bullet_list ordered_list list_item dl dt dd
      footnotes footnote_marker footnote_entry text soft_break
    ]

    expected_types.each do |type|
      it "registers '#{type}' in NODES" do
        described_class::NODES[type].should be_a(Class)
      end
    end

    it "maps each type to a Node subclass" do
      described_class::NODES.each do |_type, klass|
        klass.should be < described_class
      end
    end
  end

  describe "#initialize" do
    it "sets type from PM_TYPE constant" do
      node = described_class::Paragraph.new
      node.type.should eq("paragraph")
    end

    it "accepts custom attrs" do
      node = described_class::Paragraph.new(attrs: { id: "p1" })
      node.attrs[:id].should eq("p1")
    end

    it "accepts content" do
      text = described_class::Text.new(text: "hello")
      node = described_class::Paragraph.new(content: [text])
      node.content.size.should eq(1)
    end
  end

  describe "#to_h" do
    it "serializes type" do
      node = described_class::Paragraph.new
      node.to_h["type"].should eq("paragraph")
    end

    it "omits empty attrs" do
      node = described_class::Paragraph.new
      node.to_h.should_not have_key("attrs")
    end

    it "includes attrs when present" do
      node = described_class::Paragraph.new(attrs: { id: "p1" })
      node.to_h["attrs"].should eq({ "id" => "p1" })
    end

    it "includes content when present" do
      text = described_class::Text.new(text: "hello")
      node = described_class::Paragraph.new(content: [text])
      node.to_h["content"].should be_an(Array)
      node.to_h["content"].first["type"].should eq("text")
    end

    it "includes marks when present" do
      mark = Metanorma::Mirror::Mark::Emphasis.new
      text = described_class::Text.new(text: "hello", marks: [mark])
      text.to_h["marks"].first["type"].should eq("emphasis")
    end
  end

  describe ".from_h" do
    it "reconstructs a paragraph node" do
      hash = { "type" => "paragraph", "attrs" => { "id" => "p1" } }
      node = described_class.from_h(hash)
      node.should be_a(described_class::Paragraph)
      node.attrs[:id].should eq("p1")
    end

    it "reconstructs text node with custom_from_h" do
      hash = { "type" => "text", "text" => "hello" }
      node = described_class.from_h(hash)
      node.should be_a(described_class::Text)
      node.text.should eq("hello")
    end

    it "reconstructs nested content" do
      hash = {
        "type" => "paragraph",
        "content" => [
          { "type" => "text", "text" => "hello" },
        ],
      }
      node = described_class.from_h(hash)
      node.content.first.should be_a(described_class::Text)
      node.content.first.text.should eq("hello")
    end

    it "reconstructs text with marks" do
      hash = {
        "type" => "text",
        "text" => "bold",
        "marks" => [{ "type" => "strong" }],
      }
      node = described_class.from_h(hash)
      node.marks.first.should be_a(Metanorma::Mirror::Mark::Strong)
    end

    it "returns nil for nil input" do
      described_class.from_h(nil).should be_nil
    end
  end

  describe "round-trip" do
    it "preserves all data through to_h → from_h" do
      text = described_class::Text.new(text: "hello", marks: [Metanorma::Mirror::Mark::Emphasis.new])
      para = described_class::Paragraph.new(
        attrs: { id: "p1", alignment: "center" },
        content: [text],
      )

      round_tripped = described_class.from_h(para.to_h)
      round_tripped.should be_a(described_class::Paragraph)
      round_tripped.attrs[:id].should eq("p1")
      round_tripped.content.first.text.should eq("hello")
      round_tripped.content.first.marks.first.type.should eq("emphasis")
    end
  end

  describe "#text_content" do
    it "returns text from Text children" do
      text = described_class::Text.new(text: "hello ")
      text2 = described_class::Text.new(text: "world")
      para = described_class::Paragraph.new(content: [text, text2])
      para.text_content.should eq("hello world")
    end

    it "returns empty string for no content" do
      para = described_class::Paragraph.new(content: [])
      para.text_content.should eq("")
    end
  end
end
