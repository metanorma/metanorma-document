# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso_document"

RSpec.describe Metanorma::Mirror::Handlers::List do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_ul(xml)
    Metanorma::Document::Components::Lists::UnorderedList.from_xml(xml)
  end

  def parse_ol(xml)
    Metanorma::Document::Components::Lists::OrderedList.from_xml(xml)
  end

  def parse_dl(xml)
    Metanorma::Document::Components::Lists::DefinitionList.from_xml(xml)
  end

  describe ".bullet" do
    it "returns a BulletList hash" do
      el = parse_ul("<ul><li>A</li><li>B</li></ul>")
      result = described_class.bullet(el, context: context)
      result.type.should eq("bullet_list")
    end

    it "extracts list items" do
      el = parse_ul("<ul><li>First</li><li>Second</li></ul>")
      result = described_class.bullet(el, context: context)
      result.content.size.should eq(2)
      result.content.each { |c| c.type.should eq("list_item") }
    end
  end

  describe ".ordered" do
    it "returns an OrderedList hash" do
      el = parse_ol("<ol><li>Step 1</li><li>Step 2</li></ol>")
      result = described_class.ordered(el, context: context)
      result.type.should eq("ordered_list")
    end

    it "extracts list items" do
      el = parse_ol("<ol><li>X</li></ol>")
      result = described_class.ordered(el, context: context)
      result.content.size.should eq(1)
    end
  end

  describe ".definition" do
    it "returns a DefinitionList hash with dt/dd pairs" do
      xml = "<dl><dt>Term</dt><dd><p>Definition</p></dd></dl>"
      el = parse_dl(xml)
      result = described_class.definition(el, context: context)
      result.type.should eq("dl")
      result.content.size.should eq(2)
      result.content[0].type.should eq("dt")
      result.content[1].type.should eq("dd")
    end
  end

  describe ".list_item" do
    it "returns a ListItem hash with content from paragraphs" do
      el = Metanorma::Document::Components::Lists::ListItem.from_xml("<li><p>Text</p></li>")
      result = described_class.list_item(el, context: context)
      result.type.should eq("list_item")
      result.content.should_not be_empty
    end
  end
end
