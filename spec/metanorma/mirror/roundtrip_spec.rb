# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::MirrorToMetanorma do
  let(:forward) { Metanorma::Mirror::Transformer.new }
  let(:reverse) { described_class.new }

  describe "mirror node round-trip through to_h → from_h" do
    it "round-trips a document tree" do
      doc = Metanorma::Mirror::Node::Document.new(
        attrs: { flavor: "iso", title: "Test Doc" },
        content: [
          Metanorma::Mirror::Node::Preface.new(content: [
                                                 Metanorma::Mirror::Node::ContentSection.new(
                                                   attrs: { title: "Foreword" },
                                                   content: [
                                                     Metanorma::Mirror::Node::Paragraph.new(content: [
                                                                                              Metanorma::Mirror::Node::Text.new(text: "Foreword text"),
                                                                                            ]),
                                                   ],
                                                 ),
                                               ]),
          Metanorma::Mirror::Node::Sections.new(content: [
                                                  Metanorma::Mirror::Node::Clause.new(
                                                    attrs: { id: "s1",
                                                             title: "Scope", number: "1" },
                                                    content: [
                                                      Metanorma::Mirror::Node::Paragraph.new(
                                                        attrs: { id: "p1" },
                                                        content: [
                                                          Metanorma::Mirror::Node::Text.new(text: "Hello "),
                                                          Metanorma::Mirror::Node::Text.new(
                                                            text: "world",
                                                            marks: [Metanorma::Mirror::Mark::Emphasis.new],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ]),
        ],
      )

      hash = doc.to_h
      restored = Metanorma::Mirror::Node.from_h(hash)

      restored.should be_a(Metanorma::Mirror::Node::Document)
      restored.attrs[:flavor].should eq("iso")
      restored.content.size.should eq(2)

      preface = restored.content[0]
      preface.should be_a(Metanorma::Mirror::Node::Preface)

      sections = restored.content[1]
      clause = sections.content[0]
      clause.attrs[:title].should eq("Scope")
      clause.attrs[:number].should eq("1")

      para = clause.content[0]
      para.content[0].text.should eq("Hello ")
      para.content[1].text.should eq("world")
      para.content[1].marks.first.type.should eq("emphasis")
    end

    it "round-trips through JSON serialization" do
      doc = Metanorma::Mirror::Node::Document.new(
        attrs: { flavor: "iso" },
        content: [
          Metanorma::Mirror::Node::Sections.new(content: [
                                                  Metanorma::Mirror::Node::Clause.new(
                                                    attrs: { id: "s1" },
                                                    content: [
                                                      Metanorma::Mirror::Node::Paragraph.new(content: [
                                                                                               Metanorma::Mirror::Node::Text.new(
                                                                                                 text: "bold text",
                                                                                                 marks: [Metanorma::Mirror::Mark::Strong.new],
                                                                                               ),
                                                                                             ]),
                                                    ],
                                                  ),
                                                ]),
        ],
      )

      json = Metanorma::Mirror::Serialization::JsonSerializer.serialize(doc)
      restored = Metanorma::Mirror::Serialization::JsonSerializer.deserialize(json)

      restored.attrs[:flavor].should eq("iso")
      clause = restored.content[0].content[0]
      clause.should be_a(Metanorma::Mirror::Node::Clause)
      clause.content[0].content[0].marks.first.should be_a(Metanorma::Mirror::Mark::Strong)
    end

    it "round-trips through YAML serialization" do
      doc = Metanorma::Mirror::Node::Document.new(
        content: [
          Metanorma::Mirror::Node::Bibliography.new(content: []),
        ],
      )

      yaml = Metanorma::Mirror::Serialization::YamlSerializer.serialize(doc)
      restored = Metanorma::Mirror::Serialization::YamlSerializer.deserialize(yaml)

      restored.should be_a(Metanorma::Mirror::Node::Document)
      restored.content[0].should be_a(Metanorma::Mirror::Node::Bibliography)
    end
  end
end
