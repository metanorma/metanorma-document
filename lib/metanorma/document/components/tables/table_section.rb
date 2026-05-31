# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        class TableSection < Lutaml::Model::Serializable
          attribute :tr, TextTableRow, collection: true

          xml do
            map_element "tr", to: :tr
          end
        end
      end
    end
  end
end
