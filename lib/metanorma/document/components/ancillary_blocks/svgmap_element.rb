# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # Wrapper around an SVG figure, to update its hyperlinks with
        # (potentially document-specific) links, so that the SVG can
        # hyperlink to anchors within the document.
        class SvgmapElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :class_attr, :string
          attribute :figure, Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                    collection: true
          attribute :target, "Metanorma::Document::Components::AncillaryBlocks::SvgTargetElement", collection: true

          xml do
            element "svgmap"
            map_attribute "id", to: :id
            map_attribute "class", to: :class_attr
            map_element "figure", to: :figure
            map_element "target", to: :target
          end
        end
      end
    end
  end
end
