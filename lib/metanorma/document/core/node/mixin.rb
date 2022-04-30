# frozen_string_literal: true

module Metanorma; module Document; module Core; class Node
  # Allows for a different class hierarchy, perhaps by allowing to subclass
  # core classes.
  module Mixin
    # Mixin handling API
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    # Initialization API:
    # You can define any kind of initializer for your subclasses, for
    # example to create patterns like:
    #
    # class PElement
    #   include Metanorma::Document::Core::Node::Custom
    #   register_element "p"
    #   def initialize(text)
    #     self.xml_children = [text]
    #   end
    # end
    #
    # class MyList < Metanorma::Document::Core::Node
    #   include Metanorma::Document::Core::Node::Custom
    #   register_element "my-list"
    #   def initialize(xml_children)
    #     self.xml_children = xml_children.map do |i|
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

    def initialize_converted(ng_node); end

    def deep_dup
      dup = self.dup
      dup.initialize_deep_copy(self)
      dup
    end

    def initialize_deep_copy(_other)
      @xml_children = @xml_children&.map do |i|
        i.respond_to?(:deep_dup) ? i.deep_dup : i.dup
      end
      @xml_name = @xml_name&.map { |i| i.dup }
      @xml_attributes = @xml_attributes&.dup
    end

    # Class methods for Metanorma::Document::Core::Node::Mixin
    module ClassMethods
      def from_ng(ng_node)
        new_node = nil

        case ng_node
        when Nokogiri::XML::Document
          new_node = Top.allocate
        when Nokogiri::XML::Element
          name = ng_node.name
          xmlns = ng_node.namespace&.href
          new_node = Custom.handler_for(name, xmlns).allocate
        when Nokogiri::XML::Text
          # We represent Text nodes simply as Strings
          return ng_node.content
        when Nokogiri::XML::Comment
          return Comment.new(ng_node.content)
        end

        attributes = ng_node.attribute_nodes.map do |i|
          name = i.name
          name = "#{i.namespace.href}:#{i.name}" if i.namespace
          [name, i.value]
        end.to_h

        attributes.merge! ng_node.namespaces if ng_node.is_a? Nokogiri::XML::Document

        new_node.xml_attributes = attributes

        new_node.xml_children = ng_node.children.map do |i|
          Node.from_ng(i)
        end

        new_node.xml_name = [ng_node.name, ng_node.namespace&.href] if ng_node.is_a? Nokogiri::XML::Element

        new_node.initialize_converted(ng_node)
        new_node
      end
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

      xml_children.each do |child|
        ng_node.add_child child.to_ng(ng_document)
      end

      xml_attributes.each do |name, value|
        # Extract the namespace
        name = name.split(":")
        last = name.pop
        ns = if name.empty?
               nil
             else
               name.join(":")
             end
        name = last

        ng_node[name] = value
        if ns
          nsobj = doc.root.namespace_definitions.find { |nsdef| nsdef.href == ns }
          child.attribute(name).namespace = nsobj
        end

        ng_node.attribute_nodes << Nokogiri::XML::Attr.new(ng_document, name).tap do |i|
          i.value = value
        end
      end

      ng_node
    end

    # Access API:

    attr_accessor :xml_attributes, :xml_children, :xml_name

    def xml_namespace
      return nil if self.is_a? Top

      name = xml_name || self.class.xml_name
      name&.dig(1)
    end

    def xml_tagname
      return nil if self.is_a? Top

      name = xml_name || self.class.xml_name
      name&.dig(0)
    end

    def xml_namespace=(name)
      self.xml_name ||= self.class.xml_name || []
      self.xml_name[1] = name
    end

    def xml_tagname=(name)
      self.xml_name ||= self.class.xml_name || []
      self.xml_name[0] = name
    end

    def xml_node_children
      xml_children.select { |i| i.is_a? Node }
    end

    # Traversing API:
    # This can be used via a visitor pattern to replace or find particular nodes.
    #
    # The following example replaces all "p" nodes with their first children.
    #
    # tree.visit("p") do |i|
    #   i.xml_children.first
    # end
    #
    # To not replace a given node, make sure you return nil:
    #
    # tree.visit("p") do |i|
    #   saved = i.xml_children.first
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

    # rubocop:disable Style/OptionalBooleanParameter
    def visit(filter = nil, matched = false, &block)
      unless block_given?
        # The default is to return all nodes
        collection = []
        block = proc { |i| collection << i }
      end

      resp = block.call(self) if matched

      xml_children = self.xml_children&.map do |i|
        next i if i.instance_of?(String)

        matched = case filter
                  when nil
                    true
                  when String
                    i.xml_tagname == filter
                  when Class
                    i.instance_of?(filter)
                  else
                    raise ArgumentError
                  end

        result = i.visit(filter, matched, &block)

        matched && !result.nil? && result != i ? result : i
      end&.flatten&.select(&:itself)

      self.xml_children = xml_children if xml_children != self.xml_children

      resp = self if resp.nil?

      collection || resp
    end
    # rubocop:enable Style/OptionalBooleanParameter

    # Inspection API:
    # This API is designed to provide nice trees for debugging

    private def pretty_xml_name
      if self.is_a? Generic
        self.xml_name.first
      else
        self.class.name
      end
    end

    private def pretty_xml_attributes
      xml_attributes.map do |key, value|
        " #{key}=#{value.inspect}"
      end.join
    end

    def inspect
      endtag = "/" if xml_children.empty?
      out = "<#{pretty_xml_name}#{pretty_xml_attributes}#{endtag}>"

      unless xml_children.empty?
        out << xml_children.map(&:inspect).join
        out << "</#{pretty_xml_name}>"
      end

      out
    end

    private def pretty_print_xml_attributes(pp)
      return if xml_attributes.empty?

      pp.group 2 do
        pp.breakable
        pp.seplist(xml_attributes) do |(key, value)|
          pp.text key
          pp.text "="
          pp.pp value
        end
      end
    end

    def pretty_print(pp)
      pp.text "<"
      pp.text pretty_xml_name
      pretty_print_xml_attributes(pp)
      if xml_children.empty?
        pp.text "/>"
      else
        pp.text ">"
        pp.group 2 do
          pp.breakable
          pp.seplist(xml_children) do |child|
            pp.pp child
          end
        end
        pp.breakable
        pp.text "</"
        pp.text pretty_xml_name
        pp.text ">"
      end
    end

    # Comparison API

    def ==(other)
      self.class == other.class &&
        self.xml_tagname == other.xml_tagname &&
        self.xml_namespace == other.xml_namespace &&
        self.xml_attributes == other.xml_attributes &&
        self.xml_children == other.xml_children
    end

    alias eql? ==

    # Abstract class configuration
    module ClassMethods
      def xml_name; end
    end
  end
end; end; end; end
