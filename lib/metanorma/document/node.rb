# frozen_string_literal: true

module Metanorma; module Document
  # The top ancestors of all nodes. It won't ever be created directly.
  # This is so that gems can inherit from it, so that they can create
  # their own API.
  class Node
    # Initialization API:
    # You can define any kind of initializer for your subclasses, for
    # example to create patterns like:
    #
    # class PElement
    #   register_element "p"
    #   def initialize(text)
    #     self.children = [text]
    #   end
    # end
    #
    # class MyList < Metanorma::Document::Node
    #   register_element "my-list"
    #   def initialize(children)
    #     self.children = children.map do |i|
    #       PElement.new(i)
    #     end
    #   end
    # end
    #
    # MyList.new(['1', '2', '3'])
    # # => <my-list> <p> "1" </p>, <p> "2" </p>, <p> "3" </p> </my-list>
    #
    # But, while converting from XML, we don't want those initializers
    # to be called. For that case, we can override `initialize_converted`,
    # which will be called after the node has been fully provisioned.

    def initialize_converted(ng_node)
    end

    def self.from_ng(ng_node)
      new_node = nil

      if ng_node.is_a? Nokogiri::XML::Document
        new_node = Top.allocate
      elsif ng_node.is_a? Nokogiri::XML::Element
        name, xmlns = ng_node.name, ng_node.namespace&.href
        new_node = handler_for(name, xmlns).allocate
      elsif ng_node.is_a? Nokogiri::XML::Text
        # We represent Text nodes simply as Strings
        return ng_node.content
      elsif ng_node.is_a? Nokogiri::XML::Comment
        return Nodes::Comment.new(ng_node.content)
      end
      
      new_node.attributes = ng_node.attribute_nodes.map do |i|
        name = i.name
        name = "#{i.namespace.href}:#{i.name}" if i.namespace
        [name, i.value]
      end.to_h

      if ng_node.is_a? Nokogiri::XML::Document
        new_node.attributes.merge! ng_node.namespaces
      end

      new_node.children = ng_node.children.map do |i|
        Node.from_ng(i)
      end

      if ng_node.is_a? Nokogiri::XML::Element
        new_node.xml_name = [ng_node.name, ng_node.namespace&.href]
      end

      new_node.initialize_converted(ng_node)
      new_node
    end

    # Registration DSL:
    # This DSL allows you to create a subclass, that will automatically
    # register and Metanorma::Document will return a correct
    # class.
    #
    # To do so, you just need to do:
    #
    # class MyElement < Metanorma::Document::Node
    #   register_element "my-element"
    # end

    @handlers = {}

    singleton_class.attr_reader :handlers, :xml_name

    def self.handler_for(name, xmlns=nil)
      Node.handlers[[name, xmlns]] || Node.handlers[[name, nil]] || Nodes::Generic
    end

    def self.register_element(name, xmlns=nil)
      Node.handlers[[name, xmlns]] = self
      @xml_name = [name, xmlns]
    end

    # Serialization API:
    # This API will convert your objects to a Nokogiri tree. If you are
    # calling `to_ng` on a Top node, you don't need to provide a `document`
    # argument.

    def to_ng(ng_document)
      xml_name = self.xml_name || self.class.xml_name
      xml_name, xml_ns = *xml_name

      ng_node = Nokogiri::XML::Element.new(xml_name, ng_document)

      ng_node.add_namespace nil, xml_ns if xml_ns

      children.each do |child|
        ng_node.add_child child.to_ng(ng_document)
      end

      attributes.each do |name, value|
        # Extract the namespace
        name = name.split(':')
        last = name.pop
        if name.empty?
          ns = nil
        else
          ns = name.join(':')
        end
        name = last

        ng_node[name] = value
        if ns
          nsobj = doc.root.namespace_definitions.find { |ns| ns.href == ns }
          child.attribute(name).namespace = nsobj
        end

        ng_node.attribute_nodes << Nokogiri::XML::Attr.new(ng_document, name).tap do |i|
          i.value = value
        end
      end

      ng_node
    end

    # Access API:

    attr_accessor :attributes, :children, :xml_name

    def xml_tagname
      return nil if self.is_a? Top
      name = xml_name || self.class.xml_name
      name = xml_name.first
    end

    # Traversing API:
    # This can be used via a visitor pattern to replace or find particular nodes.
    #
    # The following example replaces all "p" nodes with their first children.
    #
    # tree.visit("p") do |i|
    #   i.children.first
    # end
    #
    # To not replace a given node, make sure you return nil:
    #
    # tree.visit("p") do |i|
    #   saved = i.children.first
    #   nil
    # end
    #
    # To remove a node, return false:
    #
    # tree.visit("p") do |i|
    #   false
    # end
    #
    # To find all nodes that match, don't supply a block:
    #
    # tree.visit("p")
    # # => [<p/>, <p/>]

    def visit(filter = nil, matched = false, &block)
      unless block
        # The default is to return all nodes
        collection = []
        block = proc { |i| collection << i }
      end

      resp = block.call(self) if matched

      self.children = children.map do |i|
        next i if i.class == String

        matched = case filter
        when nil
          true
        when String
          i.xml_tagname == filter
        when Class
          i.class == filter
        else
          raise ArgumentError
        end

        result = i.visit(filter, matched, &block)

        (matched && !result.nil? && result != i) ? result : i
      end.flatten.select(&:itself)

      resp = self if resp.nil?

      collection || resp
    end

    # Inspection API:
    # This API is designed to provide nice trees for debugging

    def pretty_xml_name
      if self.is_a? Nodes::Generic
        name = self.xml_name.first
      else
        name = self.class.name
      end
    end

    def pretty_attributes
      attributes.map do |key,value|
        " #{key}=#{value.inspect}"
      end.join
    end

    def inspect
      if children.empty?
        endtag = "/"
      end
      out = "<#{pretty_xml_name}#{pretty_attributes}#{endtag}>"

      unless children.empty?
        out << children.map(&:inspect).join
        out << "</#{pretty_xml_name}>"
      end

      out
    end

    def pretty_print_attributes(pp)
      unless attributes.empty?
        pp.group 2 do
          pp.breakable
          pp.seplist(attributes) do |(key,value)|
            pp.text key
            pp.text "="
            pp.pp value
          end
        end
      end
    end

    def pretty_print(pp)
      if children.empty?
        pp.text "<"
        pp.text pretty_xml_name
          pretty_print_attributes(pp)
        pp.text "/>"
      else
        pp.text "<"
        pp.text pretty_xml_name
          pretty_print_attributes(pp)
        pp.text ">"
        pp.group 2 do
          pp.breakable
          pp.seplist(children) do |child|
            pp.pp child
          end
        end
        pp.breakable
        pp.text "</"
        pp.text pretty_xml_name
        pp.text ">"
      end
    end
  end
end; end
