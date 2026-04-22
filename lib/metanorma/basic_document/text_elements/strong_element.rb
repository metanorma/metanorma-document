# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Strong text. Corresponds to HTML `strong`, `b`.
      class StrongElement < Metanorma::BasicDocument::TextElements::TextElement
        xml do
          element "strong"
        end
      end
    end
  end
end
