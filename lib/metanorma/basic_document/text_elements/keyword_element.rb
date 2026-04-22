# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Keyword text.
      class KeywordElement < Metanorma::BasicDocument::TextElements::TextElement
        xml do
          element "keyword"
        end
      end
    end
  end
end
