module Metanorma
  module Document
    module Components
      module Inline
        class SpanElement < Lutaml::Model::Serializable
          attribute :class_attr, :string
          attribute :style, :string
          attribute :text, :string, collection: true
          attribute :semx, SemxElement, collection: true
          attribute :span, SpanElement, collection: true
          attribute :tab, TabElement, collection: true
          attribute :sup, SupElement, collection: true
          attribute :br, BrElement, collection: true
          attribute :callout, "Metanorma::Document::Components::ReferenceElements::Callout",
                    collection: true

          xml do
            element "span"
            mixed_content
            map_attribute "class", to: :class_attr
            map_attribute "style", to: :style
            map_content to: :text
            map_element "semx", to: :semx
            map_element "span", to: :span
            map_element "tab", to: :tab
            map_element "sup", to: :sup
            map_element "br", to: :br
            map_element "callout", to: :callout
          end
        end
      end
    end
  end
end
