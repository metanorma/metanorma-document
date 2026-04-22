# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        # Base class for table sections (thead, tbody, tfoot) wrapping rows.
        class TableSection < Lutaml::Model::Serializable
          attribute :tr, TextTableRow, collection: true

          xml do
            map_element "tr", to: :tr
          end
        end

        # Table header section wrapping <thead> rows.
        class TableHeadSection < TableSection
          xml do
            element "thead"
            map_element "tr", to: :tr
          end
        end

        # Table body section wrapping <tbody> rows.
        class TableBodySection < TableSection
          xml do
            element "tbody"
            map_element "tr", to: :tr
          end
        end

        # Table footer section wrapping <tfoot> rows.
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
