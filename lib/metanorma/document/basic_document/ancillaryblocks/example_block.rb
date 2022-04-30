# frozen_string_literal: true

require "basic_document/blocks/basic_block_no_notes"

module Metanorma; module Document; module BasicDocument
  # Block containing an example illustrating a claim made in the main flow of text.
  class ExampleBlock < BasicBlockNoNotes
    register_element do
      # The caption of the block.
      nodes :name, TextElement

      # The block should be excluded from any automatic numbering of blocks of this class in the document.
      nodes :unnumbered, TrueClass

      # Define a subsequence for numbering of this example block.
      #
      # [example]
      # If this block is numbered as 7, and it has a subsequence value of XYZ,
      # this block, and all consecutive blocks of the same class and with the
      # same subsequence value, will be numbered consecutively
      # with the same number and in a subsequence: 7a, 7b, 7c etc.
      nodes :subsequence, String

      # Formula blocks contributing to example content.
      nodes :formula, StemElement

      # Unordered list blocks contributing to example content.
      nodes :list, UnorderedList

      # Quotation blocks contributing to example content.
      nodes :quote, QuoteBlock

      # Sourcecode blocks contributing to example content.
      nodes :sourcecode, SourcecodeBlock

      # Paragraph blocks contributing to example content.
      nodes :paragraphs, ParagraphWithFootnote
    end
  end
end; end; end
