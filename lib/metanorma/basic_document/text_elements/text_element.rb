# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Inline element containing text and associated formatting information,
      # but which does not contain any associated identifiers or references to identifiers.
      class TextElement < Metanorma::BasicDocument::EmptyElements::BasicElement
        attribute :content, Metanorma::BasicDocument::TextElements::TextElementType

        xml do
          element "text-element"
          map_element "content", to: :content
        end
      end
    end
  end
end
