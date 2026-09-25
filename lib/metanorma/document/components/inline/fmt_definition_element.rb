# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class FmtDefinitionElement < Lutaml::Model::Serializable
          include RenderedDisplay

          attribute :id, :string
          attribute :semx, SemxElement, collection: true
          attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true
          attribute :ol, "Metanorma::Document::Components::Lists::OrderedList",
                    collection: true
          attribute :ul, "Metanorma::Document::Components::Lists::UnorderedList",
                    collection: true
          attribute :dl, "Metanorma::Document::Components::Lists::DefinitionList"

          xml do
            element "fmt-definition"
            map_attribute "id", to: :id
            map_element "semx", to: :semx
            map_element "p", to: :p
            map_element "ol", to: :ol
            map_element "ul", to: :ul
            map_element "dl", to: :dl
          end
        end
      end
    end
  end
end
