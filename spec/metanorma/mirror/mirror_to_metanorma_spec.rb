# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::MirrorToMetanorma do
  let(:transformer) { described_class.new }

  describe "#call" do
    it "converts a paragraph node" do
      node = {
        "type" => "paragraph",
        "attrs" => { "id" => "p1" },
        "content" => [{ "type" => "text", "text" => "Hello" }],
      }
      result = transformer.call(node)
      result[:type].should eq("paragraph")
      result[:attrs]["id"].should eq("p1")
      result[:content].first[:text].should eq("Hello")
    end

    it "converts a clause with children" do
      node = {
        "type" => "clause",
        "attrs" => { "id" => "s1", "title" => "Scope" },
        "content" => [
          {
            "type" => "paragraph",
            "content" => [{ "type" => "text", "text" => "Content" }],
          },
        ],
      }
      result = transformer.call(node)
      result[:type].should eq("clause")
      result[:attrs]["id"].should eq("s1")
      result[:content].size.should eq(1)
      result[:content].first[:type].should eq("paragraph")
    end

    it "converts a document tree" do
      node = {
        "type" => "doc",
        "attrs" => { "flavor" => "iso" },
        "content" => [
          { "type" => "preface", "content" => [] },
          { "type" => "sections", "content" => [] },
        ],
      }
      result = transformer.call(node)
      result[:type].should eq("doc")
      result[:attrs]["flavor"].should eq("iso")
      result[:content].size.should eq(2)
    end

    it "converts a bullet list" do
      node = {
        "type" => "bullet_list",
        "content" => [
          {
            "type" => "list_item",
            "content" => [{ "type" => "text", "text" => "Item" }],
          },
        ],
      }
      result = transformer.call(node)
      result[:type].should eq("bullet_list")
      result[:content].first[:type].should eq("list_item")
    end

    it "converts a table" do
      node = {
        "type" => "table",
        "attrs" => { "id" => "t1" },
        "content" => [
          {
            "type" => "table_head",
            "content" => [
              {
                "type" => "table_row",
                "content" => [
                  {
                    "type" => "table_cell",
                    "content" => [{ "type" => "text", "text" => "Header" }],
                  },
                ],
              },
            ],
          },
        ],
      }
      result = transformer.call(node)
      result[:type].should eq("table")
      result[:content].first[:type].should eq("table_head")
      row = result[:content].first[:content].first
      row[:type].should eq("table_row")
    end

    it "converts admonition with type" do
      node = {
        "type" => "admonition",
        "attrs" => { "type" => "warning" },
        "content" => [],
      }
      result = transformer.call(node)
      result[:type].should eq("admonition")
      result[:attrs]["type"].should eq("warning")
    end

    it "converts sourcecode with language" do
      node = {
        "type" => "sourcecode",
        "attrs" => { "language" => "ruby", "text" => "puts 'hi'" },
      }
      result = transformer.call(node)
      result[:type].should eq("sourcecode")
      result[:attrs]["language"].should eq("ruby")
    end

    it "converts image with attrs" do
      node = {
        "type" => "image",
        "attrs" => { "src" => "img.png", "alt" => "test" },
      }
      result = transformer.call(node)
      result[:type].should eq("image")
      result[:attrs]["src"].should eq("img.png")
    end

    it "handles definition lists" do
      node = {
        "type" => "dl",
        "content" => [
          {
            "type" => "dt",
            "content" => [{ "type" => "text", "text" => "term" }],
          },
          { "type" => "dd", "content" => [] },
        ],
      }
      result = transformer.call(node)
      result[:type].should eq("dl")
      result[:content].size.should eq(2)
      result[:content].first[:type].should eq("dt")
      result[:content].last[:type].should eq("dd")
    end

    it "passes through a hash unchanged" do
      hash = { "type" => "paragraph", "attrs" => { "id" => "p1" },
               "content" => [] }
      result = transformer.call(hash)
      result[:type].should eq("paragraph")
    end

    it "converts a floating_title" do
      node = { "type" => "floating_title", "attrs" => { "id" => "ft1",
                                                        "depth" => 3 } }
      result = transformer.call(node)
      result[:type].should eq("floating_title")
      result[:attrs]["depth"].should eq(3)
    end

    it "converts an annex" do
      node = {
        "type" => "annex",
        "attrs" => { "id" => "a1", "title" => "Annex A" },
        "content" => [
          { "type" => "paragraph", "content" => [{ "type" => "text",
                                                   "text" => "Text" }] },
        ],
      }
      result = transformer.call(node)
      result[:type].should eq("annex")
      result[:content].size.should eq(1)
    end

    it "converts a content_section" do
      node = {
        "type" => "content_section",
        "attrs" => { "id" => "fw", "title" => "Foreword" },
        "content" => [],
      }
      result = transformer.call(node)
      result[:type].should eq("content_section")
      result[:attrs]["id"].should eq("fw")
    end

    it "converts preface, sections, bibliography" do
      %w[preface sections bibliography].each do |type|
        node = { "type" => type, "content" => [] }
        result = transformer.call(node)
        result[:type].should eq(type)
      end
    end

    it "converts note and example" do
      %w[note example].each do |type|
        node = { "type" => type, "attrs" => { "id" => "#{type}1" },
                 "content" => [] }
        result = transformer.call(node)
        result[:type].should eq(type)
        result[:attrs]["id"].should eq("#{type}1")
      end
    end

    it "converts quote" do
      node = { "type" => "quote", "attrs" => { "id" => "q1" },
               "content" => [] }
      result = transformer.call(node)
      result[:type].should eq("quote")
    end

    it "converts formula" do
      node = { "type" => "formula", "attrs" => { "id" => "f1",
                                                 "mathml" => "<math/>" } }
      result = transformer.call(node)
      result[:type].should eq("formula")
      result[:attrs]["mathml"].should eq("<math/>")
    end

    it "converts ordered_list" do
      node = {
        "type" => "ordered_list",
        "content" => [
          { "type" => "list_item",
            "content" => [{ "type" => "text", "text" => "First" }] },
        ],
      }
      result = transformer.call(node)
      result[:type].should eq("ordered_list")
      result[:content].first[:type].should eq("list_item")
    end

    it "converts term" do
      node = {
        "type" => "term",
        "attrs" => { "id" => "t1" },
        "content" => [
          { "type" => "paragraph", "content" => [{ "type" => "text",
                                                   "text" => "def" }] },
        ],
      }
      result = transformer.call(node)
      result[:type].should eq("term")
      result[:attrs]["id"].should eq("t1")
    end

    it "converts terms, definitions, references sections" do
      %w[terms definitions references].each do |type|
        node = { "type" => type, "attrs" => { "id" => type },
                 "content" => [] }
        result = transformer.call(node)
        result[:type].should eq(type)
      end
    end

    it "skips review nodes" do
      node = { "type" => "review", "attrs" => { "id" => "r1" } }
      result = transformer.call(node)
      result.should be_nil
    end

    it "skips footnotes nodes" do
      node = { "type" => "footnotes", "content" => [] }
      result = transformer.call(node)
      result.should be_nil
    end

    it "converts soft_break" do
      node = { "type" => "soft_break" }
      result = transformer.call(node)
      result[:type].should eq("soft_break")
    end

    it "round-trips text with marks" do
      node = {
        "type" => "paragraph",
        "content" => [
          { "type" => "text", "text" => "bold",
            "marks" => [{ "type" => "strong" }] },
        ],
      }
      result = transformer.call(node)
      text_node = result[:content].first
      text_node[:text].should eq("bold")
      text_node[:marks].first["type"].should eq("strong")
    end
  end
end
