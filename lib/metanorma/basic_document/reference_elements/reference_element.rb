# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ReferenceElements
      # Inline element, which references an identifier of a document, a block in a document, or an element
      # in a document.
      class ReferenceElement < Metanorma::BasicDocument::EmptyElements::BasicElement
        attribute :type, :string
        attribute :text, Metanorma::BasicDocument::EmptyElements::BasicElement
        attribute :alt, :string

        xml do
          element "reference-element"
          map_attribute "type", to: :type
          map_element "text", to: :text
          map_attribute "alt", to: :alt
        end
      end
    end
  end
end
