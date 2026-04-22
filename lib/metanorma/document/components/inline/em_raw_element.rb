module Metanorma
  module Document
    module Components
      module Inline
        class EmRawElement < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :semx, "Metanorma::Document::Components::Inline::SemxElement",
                    collection: true
          attribute :span, "Metanorma::Document::Components::Inline::SpanElement",
                    collection: true

          xml do
            element "em"
            mixed_content
            map_content to: :text
            map_element "semx", to: :semx
            map_element "span", to: :span
          end
        end
      end
    end
  end
end
