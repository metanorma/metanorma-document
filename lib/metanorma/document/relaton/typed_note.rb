# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A note associated with the bibliographic item.
      class TypedNote < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :format, :string
        attribute :text, :string, collection: true
        attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true

        xml do
          element "note"
          mixed_content
          map_attribute "type", to: :type
          map_attribute "format", to: :format
          map_content to: :text
          map_element "p", to: :p
        end
      end
    end
  end
end
