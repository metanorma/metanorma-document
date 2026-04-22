module Metanorma
  module Document
    module Components
      module Inline
        class FmtPreferredElement < Lutaml::Model::Serializable
          attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true

          xml do
            element "fmt-preferred"
            map_element "p", to: :p
          end
        end
      end
    end
  end
end
