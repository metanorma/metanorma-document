# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Superscript text. Corresponds to HTML `sup`.
        class SuperscriptElement < TextElement
          xml do
            element "sup"
          end
        end
      end
    end
  end
end
