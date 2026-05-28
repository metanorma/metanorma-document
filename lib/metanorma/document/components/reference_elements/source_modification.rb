# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        class SourceModification < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true

          xml do
            element "modification"
            map_attribute "id", to: :id
            map_element "p", to: :p
          end
        end
      end
    end
  end
end
