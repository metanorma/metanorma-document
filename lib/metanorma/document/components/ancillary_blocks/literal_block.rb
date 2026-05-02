# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # Pre-formatted blocks are wrappers for text to be rendered with fixed-width typeface, and preserving
        # spaces including line breaks. They are intended for a restricted number of functions, most typically
        # ASCII Art (which is still in prominent use in some standards documents), and computer output. In
        # most cases, Sourcecode blocks are more appropriate in markup, as it is more clearly motivated
        # semantically.
        class LiteralBlock < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :alt, :string
          attribute :align, :string
          attribute :name, Metanorma::Document::Components::TextElements::TextElement,
                    collection: true
          attribute :content, :string

          xml do
            element "pre"
            map_attribute "id", to: :id
            map_attribute "alt", to: :alt
            map_attribute "align", to: :align
            map_element "name", to: :name
            map_content to: :content
          end
        end
      end
    end
  end
end
