# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Listing of multiple cross-reference targets to be combined under the one element
  class XrefTargetType < Core::Node
    include Core::Node::Custom

    register_element do
      # Cross-reference target to be included in the listing.
      node :target, BasicDocument::IdElement

      # Connective linking this target to its predecessor. _from/to_ are presumed to nest more closely than
      # _and_ or _or_.
      attribute :connective, XrefConnectiveType
    end
  end
end; end; end
