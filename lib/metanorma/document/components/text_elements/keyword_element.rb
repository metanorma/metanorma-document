# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Keyword text.
        class KeywordElement < TextElement
          xml do
            element "keyword"
          end
        end
      end
    end
  end
end
