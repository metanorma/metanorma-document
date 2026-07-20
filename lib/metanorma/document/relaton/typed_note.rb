# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A note associated with the bibliographic item.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Note lacks the
      # +format+ attribute and sanitizes content to a raw string — fixtures
      # carry <note format="text/plain"> and structured <p id="...">
      # ParagraphBlocks.
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
