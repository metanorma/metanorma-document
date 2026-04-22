# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module DataTypes
      # Script identifier, as defined in ISO 15924.
      class Iso15924Code < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "iso15924-code"
          map_content to: :value
        end
      end
    end
  end
end
