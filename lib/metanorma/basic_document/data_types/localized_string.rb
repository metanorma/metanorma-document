# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module DataTypes
      # FormattedString which optionally specifies its language and/or script.
      class LocalizedString < Lutaml::Model::Serializable
        attribute :language, :string
        attribute :script, :string
        attribute :value, :string
        attribute :variant, LocalizedString

        xml do
          element "localized-string"
          map_attribute "language", to: :language
          map_attribute "script", to: :script
          map_content to: :value
          map_element "variant", to: :variant
        end
      end
    end
  end
end
