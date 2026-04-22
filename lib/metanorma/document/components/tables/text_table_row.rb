# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        # Sequence of cells to be displayed as a row in a table.
        class TextTableRow < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :semx_id, :string
          attribute :td, TextTableCell, collection: true
          attribute :th, HeaderTableCell, collection: true

          xml do
            element "tr"
            map_attribute "id", to: :id
            map_attribute "semx-id", to: :semx_id
            map_element "td", to: :td
            map_element "th", to: :th
          end

          json do
            map "td", to: :td
            map "th", to: :th
          end
        end
      end
    end
  end
end
