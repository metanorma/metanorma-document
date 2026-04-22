# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module EmptyElements
        # Line break.
        class LineBreakElement < BasicElement
          xml do
            element "br"
          end
        end
      end
    end
  end
end
