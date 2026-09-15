# frozen_string_literal: true

require "spec_helper"
require "metanorma/html"

# moxml 0.5.36 and later call the adapter with an `entity_bearing:` keyword.
# The override in lib/metanorma/html.rb must accept that keyword.
RSpec.describe "Moxml::Adapter::Nokogiri.children override" do
  let(:xml) { "<root><a/>hello<b/></root>" }

  def labels(nodes)
    nodes.map { |node| node.text? ? node.content : node.name }
  end

  it "accepts the entity_bearing keyword" do
    native = Nokogiri::XML(xml).root

    children = Moxml::Adapter::Nokogiri.children(native, entity_bearing: true)

    children.should be_an(Array)
    labels(children).should eq(%w[a hello b])
  end

  it "returns the children through Moxml::Node#children" do
    root = Moxml.new(:nokogiri).parse(xml).root

    labels(root.children).should eq(%w[a hello b])
  end

  it "parses a model from XML" do
    doc = Metanorma::IsoDocument::Root.from_xml(
      File.read(fixture_path("iso/is/document-en.presentation")),
    )

    doc.should be_a(Metanorma::IsoDocument::Root)
  end
end
