# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module AncillaryBlocks
      # Block containing an example illustrating a claim made in the main flow of text.
      class ExampleBlock < Metanorma::BasicDocument::Blocks::BasicBlockNoNotes
        # The caption of the block.
        attribute :name, Metanorma::BasicDocument::TextElements::TextElement,
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
        attribute :formula,
                  Metanorma::BasicDocument::TextElements::StemElement, collection: true

        # Unordered list blocks contributing to example content.
        attribute :list, Metanorma::BasicDocument::Lists::UnorderedList,
                  collection: true

        # Quotation blocks contributing to example content.
        attribute :quote, Metanorma::BasicDocument::MultiParagraph::QuoteBlock,
                  collection: true

        # Sourcecode blocks contributing to example content.
        attribute :sourcecode,
                  Metanorma::BasicDocument::AncillaryBlocks::SourcecodeBlock, collection: true

        # Paragraph blocks contributing to example content.
        attribute :paragraphs,
                  Metanorma::BasicDocument::Paragraphs::ParagraphWithFootnote, collection: true

        xml do
          element "example"
          map_element "name", to: :name
          map_attribute "unnumbered", to: :unnumbered
          map_attribute "subsequence", to: :subsequence
          map_element "formula", to: :formula
          map_element "list", to: :list
          map_element "quote", to: :quote
          map_element "sourcecode", to: :sourcecode
          map_element "paragraphs", to: :paragraphs
        end
      end
    end
  end
end
