# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Rewriter do
  let(:transformer) { described_class.new }

  def container_from(hash)
    Metanorma::Mirror::Model::Factory.from_h(hash)
  end

  describe "#call" do
    it "returns a Model::Container for a paragraph" do
      node = container_from(
        "type" => "paragraph",
        "attrs" => { "id" => "p1" },
        "content" => [{ "type" => "text", "text" => "Hello" }],
      )
      result = transformer.call(node)
      result.should be_a(Metanorma::Mirror::Model::Container)
      result.type.should eq("paragraph")
      result.attrs["id"].should eq("p1")
      result.content.first.should be_a(Metanorma::Mirror::Model::Text)
      result.content.first.text.should eq("Hello")
    end

    it "returns a Model::Container for a clause with children" do
      node = container_from(
        "type" => "clause",
        "attrs" => { "id" => "s1", "title" => "Scope" },
        "content" => [
          { "type" => "paragraph",
            "content" => [{ "type" => "text", "text" => "Content" }] },
        ],
      )
      result = transformer.call(node)
      result.should be_a(Metanorma::Mirror::Model::Container)
      result.type.should eq("clause")
      result.attrs["id"].should eq("s1")
      result.content.size.should eq(1)
      result.content.first.type.should eq("paragraph")
    end

    it "returns a Model::Container for a document tree" do
      node = container_from(
        "type" => "doc",
        "attrs" => { "flavor" => "iso" },
        "content" => [
          { "type" => "preface", "content" => [] },
          { "type" => "sections", "content" => [] },
        ],
      )
      result = transformer.call(node)
      result.type.should eq("doc")
      result.attrs["flavor"].should eq("iso")
      result.content.size.should eq(2)
    end

    it "preserves a bullet list" do
      node = container_from(
        "type" => "bullet_list",
        "content" => [
          { "type" => "list_item",
            "content" => [{ "type" => "text", "text" => "Item" }] },
        ],
      )
      result = transformer.call(node)
      result.type.should eq("bullet_list")
      result.content.first.type.should eq("list_item")
    end

    it "preserves a table" do
      node = container_from(
        "type" => "table",
        "attrs" => { "id" => "t1" },
        "content" => [
          { "type" => "table_head",
            "content" => [
              { "type" => "table_row",
                "content" => [
                  { "type" => "table_cell",
                    "content" => [{ "type" => "text", "text" => "Header" }] },
                ] },
            ] },
        ],
      )
      result = transformer.call(node)
      result.type.should eq("table")
      result.content.first.type.should eq("table_head")
      row = result.content.first.content.first
      row.type.should eq("table_row")
    end

    it "preserves admonition attrs" do
      node = container_from(
        "type" => "admonition",
        "attrs" => { "type" => "warning" },
        "content" => [],
      )
      result = transformer.call(node)
      result.type.should eq("admonition")
      result.attrs["type"].should eq("warning")
    end

    it "preserves sourcecode attrs" do
      node = container_from(
        "type" => "sourcecode",
        "attrs" => { "language" => "ruby", "text" => "puts 'hi'" },
      )
      result = transformer.call(node)
      result.should be_a(Metanorma::Mirror::Model::Leaf)
      result.type.should eq("sourcecode")
      result.attrs["language"].should eq("ruby")
    end

    it "preserves image attrs" do
      node = container_from(
        "type" => "image",
        "attrs" => { "src" => "img.png", "alt" => "test" },
      )
      result = transformer.call(node)
      result.should be_a(Metanorma::Mirror::Model::Leaf)
      result.type.should eq("image")
      result.attrs["src"].should eq("img.png")
    end

    it "preserves definition lists" do
      node = container_from(
        "type" => "dl",
        "content" => [
          { "type" => "dt",
            "content" => [{ "type" => "text", "text" => "term" }] },
          { "type" => "dd", "content" => [] },
        ],
      )
      result = transformer.call(node)
      result.type.should eq("dl")
      result.content.size.should eq(2)
      result.content.first.type.should eq("dt")
      result.content.last.type.should eq("dd")
    end

    it "converts a floating_title leaf" do
      node = container_from(
        "type" => "floating_title",
        "attrs" => { "id" => "ft1", "depth" => 3 },
      )
      result = transformer.call(node)
      result.should be_a(Metanorma::Mirror::Model::Leaf)
      result.type.should eq("floating_title")
      result.attrs["depth"].should eq(3)
    end

    it "preserves an annex" do
      node = container_from(
        "type" => "annex",
        "attrs" => { "id" => "a1", "title" => "Annex A" },
        "content" => [
          { "type" => "paragraph",
            "content" => [{ "type" => "text", "text" => "Text" }] },
        ],
      )
      result = transformer.call(node)
      result.type.should eq("annex")
      result.content.size.should eq(1)
    end

    it "preserves a content_section" do
      node = container_from(
        "type" => "content_section",
        "attrs" => { "id" => "fw", "title" => "Foreword" },
        "content" => [],
      )
      result = transformer.call(node)
      result.type.should eq("content_section")
      result.attrs["id"].should eq("fw")
    end

    it "preserves preface, sections, bibliography" do
      %w[preface sections bibliography].each do |type|
        node = container_from("type" => type, "content" => [])
        result = transformer.call(node)
        result.type.should eq(type)
      end
    end

    it "preserves note and example" do
      %w[note example].each do |type|
        node = container_from(
          "type" => type,
          "attrs" => { "id" => "#{type}1" },
          "content" => [],
        )
        result = transformer.call(node)
        result.type.should eq(type)
        result.attrs["id"].should eq("#{type}1")
      end
    end

    it "preserves quote" do
      node = container_from(
        "type" => "quote", "attrs" => { "id" => "q1" }, "content" => [],
      )
      result = transformer.call(node)
      result.type.should eq("quote")
    end

    it "preserves formula" do
      node = container_from(
        "type" => "formula",
        "attrs" => { "id" => "f1", "mathml" => "<math/>" },
      )
      result = transformer.call(node)
      result.type.should eq("formula")
      result.attrs["mathml"].should eq("<math/>")
    end

    it "preserves ordered_list" do
      node = container_from(
        "type" => "ordered_list",
        "content" => [
          { "type" => "list_item",
            "content" => [{ "type" => "text", "text" => "First" }] },
        ],
      )
      result = transformer.call(node)
      result.type.should eq("ordered_list")
      result.content.first.type.should eq("list_item")
    end

    it "preserves term" do
      node = container_from(
        "type" => "term",
        "attrs" => { "id" => "t1" },
        "content" => [
          { "type" => "paragraph",
            "content" => [{ "type" => "text", "text" => "def" }] },
        ],
      )
      result = transformer.call(node)
      result.type.should eq("term")
      result.attrs["id"].should eq("t1")
    end

    it "preserves terms, definitions, references sections" do
      %w[terms definitions references].each do |type|
        node = container_from(
          "type" => type,
          "attrs" => { "id" => type },
          "content" => [],
        )
        result = transformer.call(node)
        result.type.should eq(type)
      end
    end

    it "drops review nodes" do
      node = container_from("type" => "review", "attrs" => { "id" => "r1" })
      transformer.call(node).should be_nil
    end

    it "drops footnotes nodes" do
      node = container_from("type" => "footnotes", "content" => [])
      transformer.call(node).should be_nil
    end

    it "preserves soft_break" do
      node = Metanorma::Mirror::Model::SoftBreak.new
      result = transformer.call(node)
      result.should be_a(Metanorma::Mirror::Model::SoftBreak)
    end

    it "round-trips text with marks" do
      node = container_from(
        "type" => "paragraph",
        "content" => [
          { "type" => "text", "text" => "bold",
            "marks" => [{ "type" => "strong" }] },
        ],
      )
      result = transformer.call(node)
      text_node = result.content.first
      text_node.should be_a(Metanorma::Mirror::Model::Text)
      text_node.text.should eq("bold")
      text_node.marks.first.type.should eq("strong")
    end

    it "wraps raw String children as Model::Text" do
      node = Metanorma::Mirror::Model::Container.new(
        type: "paragraph",
        content: ["bare string"],
      )
      result = transformer.call(node)
      result.content.first.should be_a(Metanorma::Mirror::Model::Text)
      result.content.first.text.should eq("bare string")
    end

    it "returns nil for nil input" do
      transformer.call(nil).should be_nil
    end
  end

  describe "instance-level skip/register" do
    it "skips review and footnotes by default" do
      rewriter = described_class.new
      rewriter.skipped?("review").should be(true)
      rewriter.skipped?("footnotes").should be(true)
    end

    it "supports instance-level skip mutation without leaking to other instances" do
      rewriter1 = described_class.new
      rewriter2 = described_class.new

      rewriter1.skip("custom_type")
      rewriter1.skipped?("custom_type").should be(true)
      rewriter2.skipped?("custom_type").should be(false)
    end

    it "supports instance-level register without leaking to other instances" do
      rewriter1 = described_class.new
      rewriter2 = described_class.new

      rewriter1.register("custom_type") { |_n, _r| Metanorma::Mirror::Model::Leaf.new(type: "x1") }
      rewriter1.builders.key?("custom_type").should be(true)
      rewriter2.builders.key?("custom_type").should be(false)
    end

    it "respects instance-level skip at rewrite time" do
      rewriter = described_class.new
      rewriter.skip("paragraph")
      node = Metanorma::Mirror::Model::Container.new(type: "paragraph")
      rewriter.call(node).should be_nil
    end

    it "respects instance-level register at rewrite time" do
      rewriter = described_class.new
      rewriter.register("my_test_type") do |_node, _ctx|
        Metanorma::Mirror::Model::Leaf.new(type: "customized")
      end
      node = Metanorma::Mirror::Model::Container.new(type: "my_test_type")
      result = rewriter.call(node)
      result.type.should eq("customized")
    end

    it "accepts custom skip and builders via initializer" do
      custom_skip = Set.new(%w[review])
      custom_builders = {
        "special" => ->(_n, _r) { Metanorma::Mirror::Model::Leaf.new(type: "leaf") },
      }
      rewriter = described_class.new(skip: custom_skip, builders: custom_builders)
      rewriter.skipped?("review").should be(true)
      rewriter.skipped?("footnotes").should be(false)
      rewriter.builders.key?("special").should be(true)
    end
  end

  describe "class-level defaults" do
    after do
      described_class.default_skipped_types.delete("my_test_type")
      described_class.default_builders.delete("my_test_type")
    end

    it "seeds new instances with the default skip set" do
      described_class.skip("my_test_type")
      rewriter = described_class.new
      rewriter.skipped?("my_test_type").should be(true)
    end

    it "seeds new instances with default builders" do
      described_class.register("my_test_type") do |_n, _r|
        Metanorma::Mirror::Model::Leaf.new(type: "customized")
      end
      rewriter = described_class.new
      node = Metanorma::Mirror::Model::Container.new(type: "my_test_type")
      rewriter.call(node).type.should eq("customized")
    end

    it "does not mutate existing instances when class-level defaults change" do
      rewriter = described_class.new
      described_class.skip("late_added_type")
      rewriter.skipped?("late_added_type").should be(false)
    end
  end

  describe "full model round-trip" do
    let(:original) do
      container_from(
        "type" => "doc",
        "attrs" => { "flavor" => "iso" },
        "content" => [
          { "type" => "sections",
            "content" => [
              { "type" => "clause",
                "attrs" => { "id" => "s1" },
                "content" => [
                  { "type" => "paragraph",
                    "content" => [
                      { "type" => "text", "text" => "Hello " },
                      { "type" => "text", "text" => "world",
                        "marks" => [{ "type" => "emphasis" }] },
                    ] },
                ] },
            ] },
          { "type" => "review", "attrs" => { "id" => "r1" } },
        ],
      )
    end

    it "rebuilds the model and drops skipped types" do
      rebuilt = transformer.call(original)
      rebuilt.should be_a(Metanorma::Mirror::Model::Container)
      rebuilt.type.should eq("doc")
      sections = rebuilt.content.first
      sections.type.should eq("sections")
      clause = sections.content.first
      para = clause.content.first
      para.type.should eq("paragraph")
      para.content[0].text.should eq("Hello ")
      para.content[1].text.should eq("world")
      para.content[1].marks.first.type.should eq("emphasis")
    end

    it "produces output that serializes back to equivalent JSON" do
      rebuilt = transformer.call(original)
      json = Metanorma::Mirror::Serialization::JsonSerializer.serialize(rebuilt)
      restored = Metanorma::Mirror::Serialization::JsonSerializer.deserialize(json)
      restored.type.should eq("doc")
    end
  end
end
