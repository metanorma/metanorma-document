module Metanorma
  module Document
    module Components
      module Inline
        class VariantTitleElement < Lutaml::Model::Serializable
          attribute :type, :string
          attribute :id, :string
          attribute :text, :string, collection: true
          attribute :span, SpanElement, collection: true
          attribute :semx, SemxElement, collection: true
          attribute :br, BrElement, collection: true

          xml do
            element "variant-title"
            mixed_content
            map_attribute "type", to: :type
            map_attribute "id", to: :id
            map_content to: :text
            map_element "span", to: :span
            map_element "semx", to: :semx
            map_element "br", to: :br
          end
        end
      end
    end
  end
end
