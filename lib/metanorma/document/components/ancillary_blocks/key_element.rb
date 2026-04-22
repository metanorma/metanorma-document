# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # Key definitions for formula or figure variables.
        class KeyElement < Lutaml::Model::Serializable
          attribute :class_attr, :string
          attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement
          attribute :dl, Metanorma::Document::Components::Lists::DefinitionList
          attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true

          xml do
            element "key"
            map_attribute "class", to: :class_attr
            map_element "name", to: :name
            map_element "dl", to: :dl
            map_element "p", to: :p
          end
        end
      end
    end
  end
end
