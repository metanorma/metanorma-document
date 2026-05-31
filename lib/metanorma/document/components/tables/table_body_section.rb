# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        class TableBodySection < TableSection
          xml do
            element "tbody"
            map_element "tr", to: :tr
          end
        end
      end
    end
  end
end
