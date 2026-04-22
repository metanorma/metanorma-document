module Metanorma
  module Document
    module Components
      module Inline
        class FmtTitleElement < Lutaml::Model::Serializable
          attribute :depth, :string
          attribute :id, :string
          attribute :text, :string, collection: true
          attribute :span, SpanElement, collection: true
          attribute :semx, SemxElement, collection: true
          attribute :strong, StrongRawElement, collection: true
          attribute :br, BrElement, collection: true

          xml do
            element "fmt-title"
            mixed_content
            map_attribute "depth", to: :depth
            map_attribute "id", to: :id
            map_content to: :text
            map_element "span", to: :span
            map_element "semx", to: :semx
            map_element "strong", to: :strong
            map_element "br", to: :br
          end
        end
      end
    end
  end
end
