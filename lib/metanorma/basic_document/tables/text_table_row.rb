# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Tables
      # Sequence of cells to be displayed as a row in a table.
      class TextTableRow < Lutaml::Model::Serializable
        attribute :td, Metanorma::BasicDocument::Tables::TableCell,
                  collection: true
        attribute :th, Metanorma::BasicDocument::Tables::TableCell,
                  collection: true

        xml do
          element "tr"
          map_element "td", to: :td
          map_element "th", to: :th
        end
      end
    end
  end
end
