# frozen_string_literal: true

require_relative "../inline/fmt_ladl_label_data"

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
          # Set when the division is an update unit: amended on its own,
          # independently of the publication that contains it.
          attribute :update_unit,
                    Metanorma::Document::Components::UpdateUnits::UpdateUnit
          # Optional persisted LADL label/numbering metadata for this division.
          attribute :fmt_ladl_label_data,
                    Metanorma::Document::Components::Inline::FmtLadlLabelData

          xml do
            element "basic-section"
            map_element "title", to: :title
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_element "language", to: :language
            map_element "script", to: :script
            map_element "blocks", to: :blocks
            map_element "notes", to: :notes
            map_element "update-unit", to: :update_unit
            map_element "fmt-ladl-label-data", to: :fmt_ladl_label_data
          end
        end
      end
    end
  end
end
