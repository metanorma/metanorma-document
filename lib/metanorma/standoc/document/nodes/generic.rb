module Metanorma; module Standoc; module Document; module Nodes
  # A generic kind of node. If no node has been resolved, we end up
  # here. This node tries to be as universal as possible, even to
  # a point of defining generic method_missing getters and setters for
  # XML properties.
  #
  # In the future this can be amended to generate only the properties
  # based on the RelaxNG definition.
  class Generic < Node
    # Generate a new generic node
    def initialize(xml_name, children = [], **attributes)
      xml_name = [xml_name, nil] unless xml_name.is_a? Array
      @xml_name = xml_name
      @children = children
      @attributes = attributes
    end

    # Find an attribute
    def method_missing(name, *args, **kwargs)
      if name.end_with? '='
        # Dealing with a setter
        super if args.length != 1 || !kwargs.empty?

        name = name.to_s[0..-2]

        attributes[name] = args.first
      elsif name.end_with? '?'
        # A checker. Returns true if such an attribute exists.
        super if !args.empty? || !kwargs.empty?

        name = name.to_s[0..-2]

        attributes.key?(name)
      elsif name.end_with? '!'
        # Exclaimers are not supported
        super
      else
        # A getter.
        name = name.to_s

        attributes[name]
      end
    end
  end
end; end; end; end
