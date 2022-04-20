# frozen_string_literal: true

module Metanorma; module Document; module Core; module Nodes
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

    # Find an attribute
    def method_missing(name, *args, **kwargs)
      if name.end_with? "="
        # Dealing with a setter
        super if args.length != 1 || !kwargs.empty?

        name = name.to_s[0..-2]

        xml_attributes[name] = args.first
      elsif name.end_with? "?"
        # A checker. Returns true if such an attribute exists.
        super if !args.empty? || !kwargs.empty?

        name = name.to_s[0..-2]

        xml_attributes.key?(name)
      elsif name.end_with? "!"
        # Exclaimers are not supported
        super
      else
        # A getter.
        name = name.to_s

        xml_attributes[name]
      end
    end

    # We respond to all (most?) missing xml_attributes
    def respond_to_missing?(*)
      true
    end
  end
end; end; end; end
