# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        class ColGroupElement < Lutaml::Model::Serializable
          attribute :col, ColElement, collection: true

          xml do
            element "colgroup"
            map_element "col", to: :col
          end
        end
      end
    end
  end
end
