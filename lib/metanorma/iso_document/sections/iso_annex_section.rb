# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Annex appearing in ISO/IEC document.
      class IsoAnnexSection < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :number, :string
        attribute :obligation, :string
        attribute :title, Metanorma::Document::Components::Inline::TitleWithAnnotationElement

        # Sub-clauses within annex.
        attribute :clause, IsoClauseSection,
                  collection: true

        # Appendixes to annex.
        attribute :appendix, IsoClauseSection,
                  collection: true

        # Block collections
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
        attribute :quote_blocks,
                  Metanorma::Document::Components::MultiParagraph::QuoteBlock,
                  collection: true
        attribute :definition_lists,
                  Metanorma::Document::Components::Lists::DefinitionList,
                  collection: true

        # Terms sections within annex
        attribute :terms,
                  IsoTermsSection, collection: true

        # Definitions sections within annex
        attribute :definitions,
                  Metanorma::StandardDocument::Sections::DefinitionSection,
                  collection: true

        # References sections within annex
        attribute :references,
                  Metanorma::StandardDocument::Sections::StandardReferencesSection,
                  collection: true

        # Page breaks
        attribute :pagebreak,
                  Metanorma::Document::Components::EmptyElements::PageBreakElement,
                  collection: true

        # Presentation-specific attributes
        attribute :semx_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer
        attribute :inline_header, :string
        attribute :anchor, :string
        attribute :language, :string
        attribute :script, :string
        attribute :fmt_title, Metanorma::Document::Components::Inline::FmtTitleElement
        attribute :fmt_xref_label,
                  Metanorma::Document::Components::Inline::FmtXrefLabelElement, collection: true
        attribute :variant_title,
                  Metanorma::Document::Components::Inline::VariantTitleElement, collection: true
        attribute :fmt_annotation_start,
                  Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
                  collection: true
        attribute :fmt_annotation_end,
                  Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
                  collection: true

        xml do
          element "annex"
          ordered
          map_attribute "id", to: :id
          map_attribute "number", to: :number
          map_attribute "obligation", to: :obligation, render_empty: true
          map_attribute "anchor", to: :anchor
          map_element "title", to: :title
          map_element "variant-title", to: :variant_title
          map_element "fmt-title", to: :fmt_title
          map_element "fmt-xref-label", to: :fmt_xref_label
          map_element "clause", to: :clause
          map_element "appendix", to: :appendix
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
          map_element "quote", to: :quote_blocks
          map_element "dl", to: :definition_lists
          map_element "terms", to: :terms
          map_element "definitions", to: :definitions
          map_element "references", to: :references
          map_element "pagebreak", to: :pagebreak
          map_element "fmt-annotation-start", to: :fmt_annotation_start
          map_element "fmt-annotation-end", to: :fmt_annotation_end
          map_attribute "semx-id", to: :semx_id
          map_attribute "autonum", to: :autonum
          map_attribute "displayorder", to: :displayorder
          map_attribute "inline-header", to: :inline_header
          map_attribute "language", to: :language, render_empty: true
          map_attribute "script", to: :script, render_empty: true
        end

        # Blocks in document order
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
          map "number", to: :number
          map "obligation", to: :obligation
          map "title", to: :title
          map "clause", to: :clause
          map "appendix", to: :appendix
          map "paragraphs", to: :paragraphs
          map "unordered_lists", to: :unordered_lists
          map "ordered_lists", to: :ordered_lists
          map "tables", to: :tables
          map "figures", to: :figures
          map "formulas", to: :formulas
          map "examples", to: :examples
          map "notes", to: :notes
          map "admonitions", to: :admonitions
          map "sourcecode_blocks", to: :sourcecode_blocks
          map "quote_blocks", to: :quote_blocks
          map "definition_lists", to: :definition_lists
        end
      end
    end
  end
end
