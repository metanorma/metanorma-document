# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module DataTypes
        # Country and country subdivisions identifier, as defined in ISO 3166.
        class Iso3166Code < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            element "iso3166-code"
            map_content to: :value
          end
        end
      end
    end
  end
end
