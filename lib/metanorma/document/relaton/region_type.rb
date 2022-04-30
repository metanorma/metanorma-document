# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Encoding of region with ISO 3166 encoding.
  class RegionType < Core::Node
    include Core::Node::Custom

    register_element do
      # ISO 3166 encoding.
      attribute :iso, String

      # Whether the region should be included in rendering of the place, for disambiguation.
      attribute :recommended, TrueClass

      # Name of the region.
      attribute :content, String
    end
  end
end; end; end
