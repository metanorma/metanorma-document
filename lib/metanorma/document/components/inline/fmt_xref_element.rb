module Metanorma
  module Document
    module Components
      module Inline
        class FmtXrefElement < Lutaml::Model::Serializable
          attribute :target, :string
          attribute :type, :string
          attribute :text, :string, collection: true
          attribute :span, SpanElement, collection: true
          attribute :semx, SemxElement, collection: true

          xml do
            element "fmt-xref"
            mixed_content
            map_attribute "target", to: :target
            map_attribute "type", to: :type
            map_content to: :text
            map_element "span", to: :span
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
