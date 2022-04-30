# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Coordinate point to be used within an image map.
  class ImageMapCoords < Core::Node
    include Core::Node::Custom

    register_element do
      # X-coordinate of the coordinate point.
      attribute :x, Float

      # Y-coordinate of the coordinate point.
      attribute :y, Float
    end
  end
end; end; end
