# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Subscript text. Corresponds to HTML `sub`.
        class SubscriptElement < TextElement
          xml do
            element "sub"
          end
        end
      end
    end
  end
end
