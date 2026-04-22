# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Foreword section of an ISO/IEC document.
      # Uses `ordered` to enable `each_mixed_content` for document-order iteration.
      # Maps direct block children (no <blocks> wrapper).
      class IsoForewordSection < Lutaml::Model::Serializable
        # Element identifier
        attribute :id, :string

        # Title text (may contain fmt-annotation-end in presentation XML)
        attribute :title, Metanorma::Document::Components::Inline::TitleWithAnnotationElement

        # Block collections — using base classes with correct ISO XML element names
        attribute :paragraphs,
                  Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true
        attribute :unordered_lists,
                  Metanorma::Document::Components::Lists::UnorderedList,
                  collection: true
        attribute :ordered_lists,
                  Metanorma::Document::Components::Lists::OrderedList,
                  collection: true
        attribute :tables,
                  Metanorma::Document::Components::Tables::TableBlock,
                  collection: true
        attribute :figures,
                  Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                  collection: true
        attribute :formulas,
                  Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
                  collection: true
        attribute :examples,
                  Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                  collection: true
        attribute :notes,
                  Metanorma::Document::Components::Blocks::NoteBlock,
                  collection: true
        attribute :admonitions,
                  Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                  collection: true
        attribute :sourcecode_blocks,
                  Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
                  collection: true
        attribute :definition_lists,
                  Metanorma::Document::Components::Lists::DefinitionList,
                  collection: true
        attribute :quote_blocks,
                  Metanorma::Document::Components::MultiParagraph::QuoteBlock,
                  collection: true

        # Presentation-specific attributes
        attribute :anchor, :string
        attribute :obligation, :string
        attribute :semx_id, :string
        attribute :displayorder, :integer
        attribute :fmt_title, Metanorma::Document::Components::Inline::FmtTitleElement
        attribute :fmt_annotation_start,
                  Metanorma::Document::Components::Inline::FmtAnnotationStartElement, collection: true
        attribute :fmt_annotation_end,
                  Metanorma::Document::Components::Inline::FmtAnnotationEndElement, collection: true

        xml do
          element "foreword"
          ordered
          map_attribute "id", to: :id
          map_attribute "anchor", to: :anchor
          map_attribute "obligation", to: :obligation
          map_element "title", to: :title
          map_element "fmt-title", to: :fmt_title
          map_element "p", to: :paragraphs
          map_element "ul", to: :unordered_lists
          map_element "ol", to: :ordered_lists
          map_element "table", to: :tables
          map_element "figure", to: :figures
          map_element "formula", to: :formulas
          map_element "example", to: :examples
          map_element "note", to: :notes
          map_element "admonition", to: :admonitions
          map_element "sourcecode", to: :sourcecode_blocks
          map_element "dl", to: :definition_lists
          map_element "quote", to: :quote_blocks
          map_attribute "semx-id", to: :semx_id
          map_attribute "displayorder", to: :displayorder
          map_element "fmt-annotation-start", to: :fmt_annotation_start
          map_element "fmt-annotation-end", to: :fmt_annotation_end
        end

        # Blocks in document order, used by JSON serialization
        def blocks
          @blocks ||=
            begin
              result = []
              each_mixed_content do |node|
                result << node unless node.is_a?(String)
              end
              result
            end
        end

        json do
          map "id", to: :id
          map "title", to: :title
          map "paragraphs", to: :paragraphs
          map "unordered_lists", to: :unordered_lists
          map "ordered_lists", to: :ordered_lists
          map "tables", to: :tables
          map "figures", to: :figures
          map "formulas", to: :formulas
          map "examples", to: :examples
          map "notes", to: :notes
        end
      end
    end
  end
end
