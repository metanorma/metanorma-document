# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        class TableFootSection < TableSection
          xml do
            element "tfoot"
            map_element "tr", to: :tr
          end
        end
      end
    end
  end
end
