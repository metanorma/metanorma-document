# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Inline element containing text and associated formatting information,
        # but which does not contain any associated identifiers or references to identifiers.
        class TextElement < Metanorma::Document::Components::EmptyElements::BasicElement
          attribute :content, TextElementType

          xml do
            element "text-element"
            map_element "content", to: :content
          end
        end
      end
    end
  end
end
