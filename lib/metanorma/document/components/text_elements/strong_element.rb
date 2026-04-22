# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Strong text. Corresponds to HTML `strong`, `b`.
        class StrongElement < TextElement
          xml do
            element "strong"
          end
        end
      end
    end
  end
end
