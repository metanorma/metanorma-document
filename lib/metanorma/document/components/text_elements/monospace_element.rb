# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Monospace text. Corresponds to HTML `tt`, `code`.
        class MonospaceElement < TextElement
          xml do
            element "monospace"
          end
        end
      end
    end
  end
end
