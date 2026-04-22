# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Small caps text.
        class SmallCapsElement < TextElement
          xml do
            element "smallcap"
          end
        end
      end
    end
  end
end
