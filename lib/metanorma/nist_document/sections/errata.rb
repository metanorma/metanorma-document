# frozen_string_literal: true

module Metanorma
  module NistDocument
    module Sections
      class Errata < Lutaml::Model::Serializable
        attribute :rows, ErrataRow, collection: true

        xml do
          element "errata"
          map_element "row", to: :rows
        end
      end
    end
  end
end
