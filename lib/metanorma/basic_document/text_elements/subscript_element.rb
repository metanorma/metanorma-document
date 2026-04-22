# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Subscript text. Corresponds to HTML `sub`.
      class SubscriptElement < Metanorma::BasicDocument::TextElements::TextElement
        xml do
          element "sub"
        end
      end
    end
  end
end
