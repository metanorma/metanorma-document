# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module EmptyElements
      # Page break. Only applicable in paged layouts (e.g. PDF, Word), and not
      # flow layouts (e.g. HTML).
      class PageBreakElement < Metanorma::BasicDocument::EmptyElements::BasicElement
        xml do
          element "pagebreak"
        end
      end
    end
  end
end
