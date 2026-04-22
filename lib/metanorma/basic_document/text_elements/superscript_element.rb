# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Superscript text. Corresponds to HTML `sup`.
      class SuperscriptElement < Metanorma::BasicDocument::TextElements::TextElement
        xml do
          element "sup"
        end
      end
    end
  end
end
