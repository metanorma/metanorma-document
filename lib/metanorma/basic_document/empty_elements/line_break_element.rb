# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module EmptyElements
      # Line break.
      class LineBreakElement < Metanorma::BasicDocument::EmptyElements::BasicElement
        xml do
          element "br"
        end
      end
    end
  end
end
