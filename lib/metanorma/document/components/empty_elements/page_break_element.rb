# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module EmptyElements
        # Page break. Only applicable in paged layouts (e.g. PDF, Word), and not
        # flow layouts (e.g. HTML).
        class PageBreakElement < BasicElement
          attribute :orientation, :string

          xml do
            element "pagebreak"
            map_attribute "orientation", to: :orientation
          end
        end
      end
    end
  end
end
