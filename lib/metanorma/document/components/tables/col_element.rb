# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        class ColElement < Lutaml::Model::Serializable
          attribute :width, :string

          xml do
            element "col"
            map_attribute "width", to: :width
          end
        end
      end
    end
  end
end
