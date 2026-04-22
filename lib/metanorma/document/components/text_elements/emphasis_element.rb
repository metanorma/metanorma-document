# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Emphasised text. Corresponds to HTML `em`, `i`.
        class EmphasisElement < TextElement
          xml do
            element "emphasis"
          end
        end
      end
    end
  end
end
