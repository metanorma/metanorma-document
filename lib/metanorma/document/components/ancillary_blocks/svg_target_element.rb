# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # A cross-reference overwriting an SVG file's own hyperlink, so
        # the SVG can link to anchors within the document. `href` names
        # the link in the SVG file to overwrite.
        class SvgTargetElement < Lutaml::Model::Serializable
          attribute :href, :string
          attribute :xref, Metanorma::Document::Components::Inline::XrefElement
          attribute :link, Metanorma::Document::Components::Inline::LinkElement
          attribute :eref, Metanorma::Document::Components::Inline::ErefElement

          xml do
            element "target"
            map_attribute "href", to: :href
            map_element "xref", to: :xref
            map_element "link", to: :link
            map_element "eref", to: :eref
          end
        end
      end
    end
  end
end
