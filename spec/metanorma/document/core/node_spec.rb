# frozen_string_literal: true

RSpec.describe Metanorma::Document::Core::Node do
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

    it "top element 'basic' has 5 xml_children" do
      document.root.xml_children.length.should be 5
    end

    it "top element 'basic' has 2 Node xml_children" do
      document.root.xml_node_children.length.should be 2
    end

    it "first child of 'basic' is a comment" do
      document.root.xml_node_children.first.class.should be Metanorma::Document::Core::Node::Comment
    end

    it "last child of 'basic' is a Generic" do
      document.root.xml_node_children.last.class.should be Metanorma::Document::Core::Node::Generic
    end

    let(:example_node) { document.root.xml_node_children.last }

    it "example node has 5 'p' xml_children" do
      example_node.xml_node_children.map(&:xml_tagname).should be == ["p"] * 5
    end

    it "example node has type='list' attribute" do
      example_node.xml_attributes.should be == { "type" => "list" }
    end
  end

  describe "#deep_dup" do
    let(:document) { fixture(:basic) }

    it "triggers a deep duplication" do
      doc1 = document
      doc2 = doc1.deep_dup

      doc1.__id__.should_not be == doc2.__id__
      doc1.root.__id__.should_not be == doc2.root.__id__
      doc1.root.xml_node_children.last.__id__.should_not be == doc2.root.xml_node_children.last.__id__
    end

    it "creates an equal document" do
      doc1 = document
      doc2 = doc1.deep_dup

      doc1.should be == doc2
    end
  end

  describe "#==" do
    it "equals for similar nodes" do
      node1 = described_class.new
      node1.xml_tagname = "p"
      node1.xml_children = ["Hello world!"]

      node2 = described_class.new
      node2.xml_tagname = "p"
      node2.xml_children = ["Hello world!"]

      node1.should be == node2
    end

    it "catches differences for dissimilar nodes" do
      node1 = described_class.new
      node1.xml_tagname = "p"
      node1.xml_children = ["Hello world!"]

      node2 = node1.deep_dup
      node2.xml_tagname = "P"

      node3 = node1.deep_dup
      node3.xml_children << "asdf"

      node4 = node1.deep_dup
      node4.xml_children << node3

      node5 = node1.deep_dup
      node5.xml_namespace = "http://example.com"

      node6 = node1.deep_dup
      node6.xml_attributes = { "hello" => "world" }

      node7 = Metanorma::Document::Core::Node::Comment.new("hello world")

      node1.should_not be == node2
      node1.should_not be == node3
      node1.should_not be == node4
      node1.should_not be == node5
      node1.should_not be == node6
      node1.should_not be == node7
    end
  end

  describe "#visit" do
    let(:document) { fixture(:basic) }

    it "works without a block" do
      ps = document.visit("p")
      ps.map(&:xml_tagname).should be == ["p"] * 5
    end

    it "doesn't modify the xml_children if block returns nil" do
      doc = document.deep_dup
      doc.visit("p") { nil }
      doc.should be == document
    end

    it "removes the xml_children if block returns false" do
      doc = document.deep_dup
      removed = false
      doc.visit("p") do
        if removed == false
          removed = true
          next false
        end
      end
      doc.root.xml_node_children.last.xml_node_children.length.should be 4
    end

    it "updates the xml_children" do
      doc = document.deep_dup
      doc.visit("p") { |i| i.xml_children.first }
      doc.root.xml_node_children.last.xml_children.reject { |i| i.strip == "" }.should be == ["Hello world!"] * 5
    end
  end

  describe "subclassing" do
    def generate_class_and_xml(init: -> {}, init_conv: ->(_) {})
      r = rand(1_200_000)
      klass = Class.new(described_class) do
        include Metanorma::Document::Core::Node::Custom
        register_element "tag-#{r}"

        define_method :initialize, &init
        define_method :initialize_converted, &init_conv
      end
      xml = "<some-document><tag-#{r}/></some-document>"

      [xml, klass, "tag-#{r}"]
    end

    it "correctly resolves a custom tag" do
      xml, klass = generate_class_and_xml

      doc = parse(xml)
      doc.root.xml_children.first.class.should be klass
    end

    it "correctly returns xml_tagname for a custom tag" do
      _, klass, tagname = generate_class_and_xml

      obj = klass.new
      obj.class.should be klass
      obj.xml_tagname.should be == tagname
    end

    it "correctly calls initialize_converted only upon converting" do
      counter = 0

      xml, klass = generate_class_and_xml init_conv: ->(_) { counter += 1 }

      klass.new
      counter.should be 0
      doc = parse(xml)
      counter.should be 1
      doc.deep_dup
      counter.should be 1
    end

    it "correctly calls initialize only upon creating" do
      counter = 0

      xml, klass = generate_class_and_xml init: -> { counter += 1 }

      klass.new
      counter.should be 1
      doc = parse(xml)
      counter.should be 1
      doc.deep_dup
      counter.should be 1
    end
  end
end
