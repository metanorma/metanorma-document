module Metanorma
  module Document
    module Components
      module Inline
        class StrongRawElement < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :semx, "Metanorma::Document::Components::Inline::SemxElement",
                    collection: true
          attribute :span, "Metanorma::Document::Components::Inline::SpanElement",
                    collection: true
          attribute :br, BrElement, collection: true

          xml do
            element "strong"
            mixed_content
            map_content to: :text
            map_element "semx", to: :semx
            map_element "span", to: :span
            map_element "br", to: :br
          end
        end
      end
    end
  end
end
