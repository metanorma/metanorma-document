# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Emphasised text. Corresponds to HTML `em`, `i`.
      class EmphasisElement < Metanorma::BasicDocument::TextElements::TextElement
        xml do
          element "emphasis"
        end
      end
    end
  end
end
