# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module EmptyElements
      # Horizontal rule.
      class HorizontalRuleElement < Metanorma::BasicDocument::EmptyElements::BasicElement
        xml do
          element "hr"
        end
      end
    end
  end
end
