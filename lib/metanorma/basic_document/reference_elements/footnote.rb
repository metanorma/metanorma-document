# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ReferenceElements
      # Inline reference to a paragraph or paragraphs, appearing as a footnote.
      class Footnote < Metanorma::BasicDocument::ReferenceElements::ReferenceToIdWithParagraphElement
        attribute :type, BasicObject

        xml do
          element "footnote"
          map_element "type", to: :type
        end
      end
    end
  end
end
