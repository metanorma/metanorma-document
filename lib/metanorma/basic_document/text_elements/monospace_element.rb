# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Monospace text. Corresponds to HTML `tt`, `code`.
      class MonospaceElement < Metanorma::BasicDocument::TextElements::TextElement
        xml do
          element "monospace"
        end
      end
    end
  end
end
