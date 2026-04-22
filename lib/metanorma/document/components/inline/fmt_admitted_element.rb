module Metanorma
  module Document
    module Components
      module Inline
        class FmtAdmittedElement < Lutaml::Model::Serializable
          attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true

          xml do
            element "fmt-admitted"
            map_element "p", to: :p
          end
        end
      end
    end
  end
end
