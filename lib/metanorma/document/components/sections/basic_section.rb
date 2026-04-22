# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Sections
        # Group of blocks within text, which is a leaf node in the hierarchical organisation of text (does not
        # contain any sections of its own).
        class BasicSection < Lutaml::Model::Serializable
          attribute :title, Metanorma::Document::Components::TextElements::TextElement,
                    collection: true
          attribute :id, :string
          attribute :anchor, :string
          attribute :language, Metanorma::Document::Components::DataTypes::Iso639Code,
                    collection: true
          attribute :script, Metanorma::Document::Components::DataTypes::Iso15924Code,
                    collection: true
          attribute :blocks, Metanorma::Document::Components::Blocks::BasicBlock,
                    collection: true
          attribute :notes, Metanorma::Document::Components::Blocks::NoteBlock,
                    collection: true

          xml do
            element "basic-section"
            map_element "title", to: :title
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_element "language", to: :language
            map_element "script", to: :script
            map_element "blocks", to: :blocks
            map_element "notes", to: :notes
          end
        end
      end
    end
  end
end
