# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # A numbered clause in an ISO/IEC document body.
      # Supports recursive nesting via `clause` collection.
      # Uses `ordered` to enable `each_mixed_content` for document-order iteration.
      class IsoClauseSection < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :type, :string
        attribute :number, :string
        attribute :obligation, :string
        attribute :inline_header, :string
        attribute :unnumbered, :string
        attribute :toc, :string
        attribute :class_attr, :string
        attribute :title, Metanorma::Document::Components::Inline::TitleWithAnnotationElement

        # Sub-clauses (recursive)
        attribute :clause, IsoClauseSection, collection: true

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

        # Amend blocks (for amendment documents)
        attribute :amend,
                  Metanorma::StandardDocument::Blocks::AmendBlock

        # Terms sections nested inside clauses
        attribute :terms,
                  IsoTermsSection, collection: true

        # Definitions sections nested inside clauses
        attribute :definitions,
                  Metanorma::StandardDocument::Sections::DefinitionSection,
                  collection: true

        # References sections nested inside clauses
        attribute :references,
                  Metanorma::StandardDocument::Sections::StandardReferencesSection,
                  collection: true

        # Forms (HTML input forms with tables)
        attribute :form,
                  Metanorma::StandardDocument::Blocks::Form,
                  collection: true

        # Requirements / recommendations / permissions
        attribute :requirement,
                  Metanorma::StandardDocument::Blocks::RequirementModel,
                  collection: true
        attribute :recommendation,
                  Metanorma::StandardDocument::Blocks::RecommendationModel,
                  collection: true
        attribute :permission,
                  Metanorma::StandardDocument::Blocks::PermissionModel,
                  collection: true

        # Page breaks
        attribute :pagebreak,
                  Metanorma::Document::Components::EmptyElements::PageBreakElement,
                  collection: true

        # Bookmarks (inline anchors)
        attribute :bookmark,
                  Metanorma::Document::Components::IdElements::Bookmark,
                  collection: true

        # Presentation annotation markers
        attribute :fmt_annotation_start,
                  Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
                  collection: true
        attribute :fmt_annotation_end,
                  Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
                  collection: true

        # Presentation-specific attributes
        attribute :anchor, :string
        attribute :semx_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer
        attribute :fmt_title, Metanorma::Document::Components::Inline::FmtTitleElement
        attribute :fmt_xref_label, Metanorma::Document::Components::Inline::FmtXrefLabelElement,
                  collection: true
        attribute :variant_title,
                  Metanorma::Document::Components::Inline::VariantTitleElement, collection: true

        xml do
          element "clause"
          ordered
          map_attribute "id", to: :id
          map_attribute "anchor", to: :anchor
          map_attribute "type", to: :type
          map_attribute "number", to: :number
          map_attribute "obligation", to: :obligation
          map_attribute "inline-header", to: :inline_header
          map_attribute "unnumbered", to: :unnumbered
          map_attribute "toc", to: :toc
          map_attribute "class", to: :class_attr
          map_element "title", to: :title
          map_element "variant-title", to: :variant_title
          map_element "fmt-title", to: :fmt_title
          map_element "fmt-xref-label", to: :fmt_xref_label
          map_element "clause", to: :clause
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
          map_element "amend", to: :amend
          map_element "terms", to: :terms
          map_element "definitions", to: :definitions
          map_element "references", to: :references
          map_element "form", to: :form
          map_element "requirement", to: :requirement
          map_element "recommendation", to: :recommendation
          map_element "permission", to: :permission
          map_element "pagebreak", to: :pagebreak
          map_element "bookmark", to: :bookmark
          map_element "fmt-annotation-start", to: :fmt_annotation_start
          map_element "fmt-annotation-end", to: :fmt_annotation_end
          map_attribute "semx-id", to: :semx_id
          map_attribute "autonum", to: :autonum
          map_attribute "displayorder", to: :displayorder
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
          map "type", to: :type
          map "number", to: :number
          map "title", to: :title
          map "inline_header", to: :inline_header
          map "obligation", to: :obligation
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
          map "clause", to: :clause
        end
      end
    end
  end
end
