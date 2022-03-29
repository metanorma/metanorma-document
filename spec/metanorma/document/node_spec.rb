# frozen_string_literal: true

RSpec.describe Metanorma::Document::Node do
  describe "basic convertibility" do
    each_fixture_path_does "parse without exception" do |fixture_path|
      parse_path(fixture_path)
    end

    each_fixture_path_does "convert to Nokogiri form without exception" do |fixture_path|
      parse_path(fixture_path).to_ng
    end

    each_fixture_path_does "convert to Nokogiri form and back, preserving the form" do |fixture_path|
      parsed = parse_path(fixture_path)
      reparsed = parse(parsed.to_ng)

      parsed.inspect.should be == reparsed.inspect
    end
  end

  describe "correct parsing" do
    let(:document) { fixture(:basic) }

    it "has a top element 'basic'" do
      document.root.xml_tagname.should be == "basic"
    end

    it "top element 'basic' has 5 children" do
      document.root.children.length.should be 5
    end

    it "top element 'basic' has 2 Node children" do
      document.root.node_children.length.should be 2
    end

    it "first child of 'basic' is a comment" do
      document.root.node_children.first.class.should be Metanorma::Document::Nodes::Comment
    end

    it "last child of 'basic' is a Generic" do
      document.root.node_children.last.class.should be Metanorma::Document::Nodes::Generic
    end

    let(:example_node) { document.root.node_children.last }

    it "example node has 5 'p' children" do
      example_node.node_children.map(&:xml_tagname).should be == ['p'] * 5
    end

    it "example node has type='list' attribute" do
      example_node.attributes.should be == {"type" => "list"}
    end
  end
end
