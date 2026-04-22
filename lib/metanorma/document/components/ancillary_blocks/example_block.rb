# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # Block containing an example illustrating a claim made in the main flow of text.
        class ExampleBlock < Metanorma::Document::Components::Blocks::BasicBlockNoNotes
          # The caption of the block.
          attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement,
                    collection: true

          # The block should be excluded from any automatic numbering of blocks of this class in the document.
          attribute :unnumbered, :boolean

          # Define a subsequence for numbering of this example block.
          #
          # [example]
          # If this block is numbered as 7, and it has a subsequence value of XYZ,
          # this block, and all consecutive blocks of the same class and with the
          # same subsequence value, will be numbered consecutively
          # with the same number and in a subsequence: 7a, 7b, 7c etc.
          attribute :subsequence, :string

          # Formula blocks contributing to example content.
          attribute :formula, Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
                    collection: true

          # Unordered list blocks contributing to example content.
          attribute :list, Metanorma::Document::Components::Lists::UnorderedList,
                    collection: true

          # Ordered list blocks contributing to example content.
          attribute :ol, Metanorma::Document::Components::Lists::OrderedList,
                    collection: true

          # Unordered list blocks (ul element).
          attribute :ul, Metanorma::Document::Components::Lists::UnorderedList,
                    collection: true

          # Quotation blocks contributing to example content.
          attribute :quote, Metanorma::Document::Components::MultiParagraph::QuoteBlock,
                    collection: true

          # Sourcecode blocks contributing to example content.
          attribute :sourcecode,
                    Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock, collection: true

          # Table blocks contributing to example content.
          attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                    collection: true

          # Figure blocks contributing to example content.
          attribute :figure,
                    Metanorma::Document::Components::AncillaryBlocks::FigureBlock, collection: true

          # Definition list blocks contributing to example content.
          attribute :dl, Metanorma::Document::Components::Lists::DefinitionList,
                    collection: true

          # Requirement/recommendation/permission blocks inside examples.
          attribute :requirement, "Metanorma::StandardDocument::Blocks::RequirementModel",
                    collection: true
          attribute :recommendation, "Metanorma::StandardDocument::Blocks::RecommendationModel",
                    collection: true
          attribute :permission, "Metanorma::StandardDocument::Blocks::PermissionModel",
                    collection: true

          # Paragraph blocks contributing to example content.
          attribute :paragraphs,
                    Metanorma::Document::Components::Paragraphs::ParagraphWithFootnote, collection: true

          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :autonum, :string

          # Presentation-specific elements
          attribute :fmt_xref_label,
                    Metanorma::Document::Components::Inline::FmtXrefLabelElement, collection: true
          attribute :fmt_name, Metanorma::Document::Components::Inline::FmtNameElement

          attribute :json_type, :string

          def json_type
            "example"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "name", to: :name
            map "paragraphs", to: :paragraphs
          end

          xml do
            element "example"
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_attribute "autonum", to: :autonum, render_empty: true
            map_element "name", to: :name
            map_attribute "unnumbered", to: :unnumbered
            map_attribute "subsequence", to: :subsequence
            map_element "formula", to: :formula
            map_element "list", to: :list
            map_element "ol", to: :ol
            map_element "ul", to: :ul
            map_element "quote", to: :quote
            map_element "sourcecode", to: :sourcecode
            map_element "table", to: :table
            map_element "figure", to: :figure
            map_element "dl", to: :dl
            map_element "requirement", to: :requirement
            map_element "recommendation", to: :recommendation
            map_element "permission", to: :permission
            map_element "p", to: :paragraphs
            map_element "fmt-xref-label", to: :fmt_xref_label
            map_element "fmt-name", to: :fmt_name
          end
        end
      end
    end
  end
end
