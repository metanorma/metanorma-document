# frozen_string_literal: true

module Metanorma; module Document; module Core; class Node
  # A generic kind of node. If no node has been resolved, we end up
  # here. This node tries to be as universal as possible, even to
  # a point of defining generic method_missing getters and setters for
  # XML properties.
  class Generic < Node
    # Generate a new generic node
    def initialize(xml_name, xml_children = [], **xml_attributes)
      xml_name = [xml_name, nil] unless xml_name.is_a? Array
      @xml_name = xml_name
      @xml_children = xml_children
      @xml_attributes = xml_attributes
      super()
    end

    def [](attr)
      xml_attributes[attr.to_s]
    end

    def []=(attr, value)
      xml_attributes[attr.to_s] = value
    end
  end
end; end; end; end
