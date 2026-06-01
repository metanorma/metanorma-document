# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::MirrorToMetanorma do
  let(:transformer) { described_class.new }

  describe "#call" do
    it "converts a paragraph node" do
      node = Metanorma::Mirror::Node::Paragraph.new(
        attrs: { id: "p1" },
        content: [Metanorma::Mirror::Node::Text.new(text: "Hello")],
      )
      result = transformer.call(node)
      result[:type].should eq("paragraph")
      result[:attrs]["id"].should eq("p1")
      result[:content].first[:text].should eq("Hello")
    end

    it "converts a clause with children" do
      node = Metanorma::Mirror::Node::Clause.new(
        attrs: { id: "s1", title: "Scope" },
        content: [
          Metanorma::Mirror::Node::Paragraph.new(content: [
                                                   Metanorma::Mirror::Node::Text.new(text: "Content"),
                                                 ]),
        ],
      )
      result = transformer.call(node)
      result[:type].should eq("clause")
      result[:attrs]["id"].should eq("s1")
      result[:content].size.should eq(1)
      result[:content].first[:type].should eq("paragraph")
    end

    it "converts a document tree" do
      node = Metanorma::Mirror::Node::Document.new(
        attrs: { flavor: "iso" },
        content: [
          Metanorma::Mirror::Node::Preface.new(content: []),
          Metanorma::Mirror::Node::Sections.new(content: []),
        ],
      )
      result = transformer.call(node)
      result[:type].should eq("doc")
      result[:attrs]["flavor"].should eq("iso")
      result[:content].size.should eq(2)
    end

    it "converts a bullet list" do
      node = Metanorma::Mirror::Node::BulletList.new(
        content: [
          Metanorma::Mirror::Node::ListItem.new(content: [
                                                  Metanorma::Mirror::Node::Text.new(text: "Item"),
                                                ]),
        ],
      )
      result = transformer.call(node)
      result[:type].should eq("bullet_list")
      result[:content].first[:type].should eq("list_item")
    end

    it "converts a table" do
      node = Metanorma::Mirror::Node::Table.new(
        attrs: { id: "t1" },
        content: [
          Metanorma::Mirror::Node::TableHead.new(content: [
                                                   Metanorma::Mirror::Node::TableRow.new(content: [
                                                                                           Metanorma::Mirror::Node::TableCell.new(content: [
                                                                                                                                    Metanorma::Mirror::Node::Text.new(text: "Header"),
                                                                                                                                  ]),
                                                                                         ]),
                                                 ]),
        ],
      )
      result = transformer.call(node)
      result[:type].should eq("table")
      result[:content].first[:type].should eq("table_head")
      row = result[:content].first[:content].first
      row[:type].should eq("table_row")
    end

    it "converts admonition with type" do
      node = Metanorma::Mirror::Node::Admonition.new(
        attrs: { type: "warning" },
        content: [],
      )
      result = transformer.call(node)
      result[:type].should eq("admonition")
      result[:attrs]["type"].should eq("warning")
    end

    it "converts sourcecode with language" do
      node = Metanorma::Mirror::Node::Sourcecode.new(
        attrs: { language: "ruby", text: "puts 'hi'" },
      )
      result = transformer.call(node)
      result[:type].should eq("sourcecode")
      result[:attrs]["language"].should eq("ruby")
    end

    it "converts image with attrs" do
      node = Metanorma::Mirror::Node::Image.new(
        attrs: { src: "img.png", alt: "test" },
      )
      result = transformer.call(node)
      result[:type].should eq("image")
      result[:attrs]["src"].should eq("img.png")
    end

    it "handles definition lists" do
      node = Metanorma::Mirror::Node::DefinitionList.new(
        content: [
          Metanorma::Mirror::Node::DefinitionTerm.new(content: [
                                                        Metanorma::Mirror::Node::Text.new(text: "term"),
                                                      ]),
          Metanorma::Mirror::Node::DefinitionDescription.new(content: []),
        ],
      )
      result = transformer.call(node)
      result[:type].should eq("dl")
      result[:content].size.should eq(2)
      result[:content].first[:type].should eq("dt")
      result[:content].last[:type].should eq("dd")
    end

    it "accepts a hash input" do
      hash = { "type" => "paragraph", "attrs" => { "id" => "p1" },
               "content" => [] }
      result = transformer.call(hash)
      result[:type].should eq("paragraph")
    end
  end
end
