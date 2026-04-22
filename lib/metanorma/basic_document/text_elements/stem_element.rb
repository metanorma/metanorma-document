# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Mathematically formatted text.
      class StemElement < Metanorma::BasicDocument::TextElements::TextElement
        attribute :stem_type, :string
        attribute :stem_value, :string

        xml do
          element "stem"
          map_content to: :stem_value
          map_attribute "type", to: :stem_type
        end
      end
    end
  end
end
