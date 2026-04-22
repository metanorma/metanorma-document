module Metanorma
  module Document
    module Components
      module Inline
        class FmtNameElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :text, :string, collection: true
          attribute :span, SpanElement, collection: true
          attribute :semx, SemxElement, collection: true

          xml do
            element "fmt-name"
            mixed_content
            map_attribute "id", to: :id
            map_content to: :text
            map_element "span", to: :span
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
