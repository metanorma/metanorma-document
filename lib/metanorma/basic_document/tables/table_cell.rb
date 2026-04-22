# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Tables
      # Textual content constituting a basic building block of a table.
      class TableCell < Lutaml::Model::Serializable
        attribute :colspan, :integer
        attribute :rowspan, :integer
        attribute :align, :string
        attribute :valign, :string

        xml do
          element "table-cell"
          map_attribute "colspan", to: :colspan
          map_attribute "rowspan", to: :rowspan
          map_attribute "align", to: :align
          map_attribute "valign", to: :valign
        end
      end
    end
  end
end
