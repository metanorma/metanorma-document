module Metanorma
  module Document
    module Components
      module Inline
        class AttributionElement < Lutaml::Model::Serializable
          attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true

          xml do
            element "attribution"
            map_element "p", to: :p
          end
        end
      end
    end
  end
end
