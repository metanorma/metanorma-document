# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Specification of an area of an image to be hyperlinked, as part of an image map.
  class ImageMapAreaType < Core::Node
    include Core::Node::Custom

    register_element do
      # Type of an image map area of an image that is hyperlinked.
      attribute :type, ImageMapAreaTypeType

      # Element that this image map area links to.
      node :element, BasicDocument::ReferenceElement

      # Polygon defined shape of the image map area.
      nodes :coords, ImageMapCoords

      # Radius-defined shape of the image map area.
      node :radius, ImageMapRadius
    end
  end
end; end; end
