# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # One hyperlinked area of an image map: a shape (rect, circle,
        # ellipse, poly), the link it carries, and its geometry as
        # coordinate points (plus a radius for circle areas).
        class ImagemapAreaElement < Lutaml::Model::Serializable
          attribute :area_type, :string
          attribute :xref, Metanorma::Document::Components::Inline::XrefElement
          attribute :link, Metanorma::Document::Components::Inline::LinkElement
          attribute :eref, Metanorma::Document::Components::Inline::ErefElement
          attribute :coords, "Metanorma::Document::Components::AncillaryBlocks::CoordsElement", collection: true
          attribute :radius, "Metanorma::Document::Components::AncillaryBlocks::RadiusElement"

          xml do
            element "area"
            map_attribute "type", to: :area_type
            map_element "xref", to: :xref
            map_element "link", to: :link
            map_element "eref", to: :eref
            map_element "coords", to: :coords
            map_element "radius", to: :radius
          end
        end

        # A coordinate point of an image map area shape.
        class CoordsElement < Lutaml::Model::Serializable
          attribute :x, :float
          attribute :y, :float

          xml do
            element "coords"
            map_attribute "x", to: :x
            map_attribute "y", to: :y
          end
        end

        # The centre (and optional extent) of a circle image map area.
        class RadiusElement < Lutaml::Model::Serializable
          attribute :x, :float
          attribute :y, :float

          xml do
            element "radius"
            map_attribute "x", to: :x
            map_attribute "y", to: :y
          end
        end

        # Wrapper around an image figure, specifying an image map:
        # areas of the image that are hyperlinked.
        class ImagemapElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :class_attr, :string
          attribute :figure, Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                    collection: true
          attribute :area, "Metanorma::Document::Components::AncillaryBlocks::ImagemapAreaElement", collection: true

          xml do
            element "imagemap"
            map_attribute "id", to: :id
            map_attribute "class", to: :class_attr
            map_element "figure", to: :figure
            map_element "area", to: :area
          end
        end
      end
    end
  end
end
