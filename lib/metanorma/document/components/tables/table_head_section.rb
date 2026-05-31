# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        class TableHeadSection < TableSection
          xml do
            element "thead"
            map_element "tr", to: :tr
          end
        end
      end
    end
  end
end
