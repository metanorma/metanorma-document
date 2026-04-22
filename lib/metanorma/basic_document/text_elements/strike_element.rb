# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Strikethrough text. Corresponds to HTML 4 `s`.
      class StrikeElement < Metanorma::BasicDocument::TextElements::TextElement
        xml do
          element "strike"
        end
      end
    end
  end
end
