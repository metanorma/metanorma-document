# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module DataTypes
      # Language identifier, as defined in ISO 639.
      class Iso639Code < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "iso639-code"
          map_content to: :value
        end
      end
    end
  end
end
