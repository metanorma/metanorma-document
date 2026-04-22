# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module DataTypes
        # FormattedString which optionally specifies its language and/or script.
        class LocalizedString < Lutaml::Model::Serializable
          attribute :language, :string
          attribute :script, :string
          attribute :value, :string, collection: true
          attribute :variant, LocalizedString
          attribute :br, Metanorma::Document::Components::Inline::BrElement,
                    collection: true

          xml do
            element "localized-string"
            mixed_content
            map_attribute "language", to: :language
            map_attribute "script", to: :script
            map_content to: :value
            map_element "variant", to: :variant
            map_element "br", to: :br
          end
        end
      end
    end
  end
end
