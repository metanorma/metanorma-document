module Metanorma
  module Document
    module Components
      module Inline
        class LocalizedStringElement < Lutaml::Model::Serializable
          attribute :key, :string
          attribute :language, :string
          attribute :content, :string, collection: true
          attribute :br, BrElement, collection: true
          attribute :conn, :string, collection: true
          attribute :span, SpanElement, collection: true
          attribute :comma, CommaElement, collection: true
          attribute :enum_comma, EnumCommaElement, collection: true

          xml do
            element "localized-string"
            mixed_content
            map_attribute "key", to: :key
            map_attribute "language", to: :language
            map_content to: :content
            map_element "br", to: :br
            map_element "conn", to: :conn
            map_element "span", to: :span
            map_element "comma", to: :comma
            map_element "enum-comma", to: :enum_comma
          end
        end
      end
    end
  end
end
