# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Sections
      # Definition sections consist of one or more definition lists (`DefinitionCollection`),
      # are used to define symbols and
      # abbreviations used in the remainder of the document.
      #
      # They can also be used as glossaries, with simple definitions,
      # in contrast to the more elaborate definitions given in
      # terms sections.
      #
      # In addition to allowing prefatory text per section, each definition list
      # within each definition section can also be preceded by prefatory text.
      class DefinitionSection < Metanorma::StandardDocument::Sections::ClauseSection
        attribute :definitions, DefinitionSection, collection: true
        attribute :type, :string
        attribute :obligation, :string

        # Block content
        attribute :id, :string
        attribute :anchor, :string
        attribute :title, Metanorma::Document::Components::Inline::TitleWithAnnotationElement
        attribute :paragraphs,
                  Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true
        attribute :definition_lists,
                  Metanorma::Document::Components::Lists::DefinitionList,
                  collection: true
        attribute :unordered_lists,
                  Metanorma::Document::Components::Lists::UnorderedList,
                  collection: true
        attribute :example,
                  Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                  collection: true
        attribute :table,
                  Metanorma::Document::Components::Tables::TableBlock,
                  collection: true

        attribute :semx_id, :string
        attribute :original_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer

        # Presentation-specific
        attribute :fmt_title, Metanorma::Document::Components::Inline::FmtTitleElement
        attribute :fmt_xref_label, Metanorma::Document::Components::Inline::FmtXrefLabelElement,
                  collection: true

        xml do
          element "definitions"
          ordered
          map_attribute "id", to: :id
          map_attribute "anchor", to: :anchor
          map_attribute "type", to: :type
          map_attribute "obligation", to: :obligation
          map_element "title", to: :title
          map_element "p", to: :paragraphs
          map_element "dl", to: :definition_lists
          map_element "ul", to: :unordered_lists
          map_element "example", to: :example
          map_element "table", to: :table
          map_element "definitions", to: :definitions
          map_element "fmt-title", to: :fmt_title
          map_element "fmt-xref-label", to: :fmt_xref_label
          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
          map_attribute "autonum", to: :autonum
          map_attribute "displayorder", to: :displayorder
        end
      end
    end
  end
end
