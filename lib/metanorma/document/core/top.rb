# frozen_string_literal: true

module Metanorma; module Document; module Core
  # The Top class represents the super-top node, that has exactly one
  # child, which is the root document node.
  #
  # Itself it's not a node, in a DOM model it would be simply named
  # `document`.
  class Top < Node
    def root
      xml_children.first
    end

    # Convert to a Nokogiri document
    def to_ng
      doc = Nokogiri::XML::Document.new
      doc.root = root.to_ng(doc)
      doc
    end
  end
end; end; end
