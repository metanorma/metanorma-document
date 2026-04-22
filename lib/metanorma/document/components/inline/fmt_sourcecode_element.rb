module Metanorma
  module Document
    module Components
      module Inline
        class FmtSourcecodeElement < Lutaml::Model::Serializable
          attribute :lang, :string
          attribute :id, :string
          attribute :semx_id, :string
          attribute :text, :string
          attribute :span, SpanElement, collection: true
          attribute :callout, "Metanorma::Document::Components::ReferenceElements::Callout",
                    collection: true
          attribute :dl, Metanorma::Document::Components::Lists::DefinitionList

          xml do
            element "fmt-sourcecode"
            map_attribute "lang", to: :lang
            map_attribute "id", to: :id
            map_attribute "semx-id", to: :semx_id
            map_content to: :text
            map_element "span", to: :span
            map_element "callout", to: :callout
            map_element "dl", to: :dl
          end
        end
      end
    end
  end
end
