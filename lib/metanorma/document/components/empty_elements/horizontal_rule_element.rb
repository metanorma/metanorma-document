# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module EmptyElements
        # Horizontal rule.
        class HorizontalRuleElement < BasicElement
          xml do
            element "hr"
          end
        end
      end
    end
  end
end
