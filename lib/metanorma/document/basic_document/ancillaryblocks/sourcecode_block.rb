# frozen_string_literal: true

require "basic_document/blocks/basic_block_no_notes"

module Metanorma; module Document; module BasicDocument
  # Block containing computer code or comparable text.
  class SourcecodeBlock < BasicBlockNoNotes
    register_element do
      # The caption of the block.
      nodes :name, TextElement

      # The block should be excluded from any automatic numbering of blocks of this class in the document.
      nodes :unnumbered, TrueClass

      # Define a subsequence for numbering of this block; e.g. if this block would be numbered
      # as 7, but it has a subsequence value of XYZ, this block, and all consecutive blocks
      # of the same class and with the same subsequence value, will be numbered consecutively
      # with the same number and in a subsequence: 7a, 7b, 7c etc.
      nodes :subsequence, String

      # A file name associated with the source code (and which could be used to extract the source code
      # fragment to from the document, or to populate the source code fragment with from the external file,
      # in automated processing of the document).
      nodes :filename, String

      # The computer language or other notational convention that the source code is expressed in.
      nodes :lang, String

      # The computer code or other such text presented in the block, as a single unformatted string. (The
      # string should be treated as pre-formatted text, with whitespace treated as significant.)
      attribute :content, String

      # Zero or more cross-references; these are intended to be embedded within the `content` string, and
      # link to annotations.
      nodes :callouts, ReferenceToIdElement

      # Annotations to the source code; each annotation consists of zero or more paragraphs, and is intended
      # to be referenced by a callout within the source code.
      nodes :callout_annotations, ParagraphBlock
    end
  end
end; end; end
