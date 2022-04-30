# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Radius of a circle area within an image map.
  class ImageMapRadius < Core::Node
    include Core::Node::Custom

    register_element do
      # X-coordinate of the center of a circle area within the image map.
      attribute :x, Float

      # Y-coordinate of the center of a circle area within the image map.
      nodes :y, Float
    end
  end
end; end; end
