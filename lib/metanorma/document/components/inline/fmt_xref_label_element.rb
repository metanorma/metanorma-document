module Metanorma
  module Document
    module Components
      module Inline
        class FmtXrefLabelElement < Lutaml::Model::Serializable
          attribute :container, :string
          attribute :text, :string, collection: true
          attribute :semx, SemxElement, collection: true
          attribute :span, SpanElement, collection: true

          xml do
            element "fmt-xref-label"
            mixed_content
            map_attribute "container", to: :container
            map_content to: :text
            map_element "semx", to: :semx
            map_element "span", to: :span
          end
        end
      end
    end
  end
end
