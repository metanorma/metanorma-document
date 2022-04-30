# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The type of area in an image map to be hyperlinked.
  class ImageMapAreaTypeType < Core::Node::Enum
    # Rectangle.
    RECT = new("rect")

    # Circle.
    CIRCLE = new("circle")

    # Ellipse.
    ELLIPSE = new("ellipse")

    # Polygon.
    POLY = new("poly")
  end
end; end; end
