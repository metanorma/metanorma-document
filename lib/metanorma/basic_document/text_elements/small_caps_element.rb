# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Small caps text.
      class SmallCapsElement < Metanorma::BasicDocument::TextElements::TextElement
        xml do
          element "smallcap"
        end
      end
    end
  end
end
