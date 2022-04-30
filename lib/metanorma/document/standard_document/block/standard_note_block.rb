# frozen_string_literal: true

require "standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  class StandardNoteBlock < StandardBlockNoNotes
    register_element do
      # Do not permit a page break between the lines of the block in paged media.
      nodes :keep_lines_together, TrueClass

      # Keep this block on the same page as the following block in paged media.
      nodes :keep_with_next, TrueClass

      # Override the numbering of this block in numbering.
      nodes :number, String

      # Define a subsequence for numbering of this block; e.g. if this block would be numbered
      # as 7, but it has a subsequence value of XYZ, this block, and all consecutive blocks
      # of the same class and with the same subsequence value, will be numbered consecutively
      # with the same number and in a subsequence: 7a, 7b, 7c etc.
      nodes :subsequence, String

      # Do not number this block in rendering.
      nodes :unnumbered, TrueClass

      # Display the note on the document cover page.
      nodes :cover_page, TrueClass

      # Do not insert text labelling the note as a note in rendering.
      nodes :notag, TrueClass

      # Semantic classification of note.
      nodes :type, String

      # Unordered list included within note.
      nodes :ul, BasicDocument::UnorderedList

      # Ordered list included within note.
      nodes :ol, BasicDocument::OrderedList

      # Definition list included within note.
      nodes :dl, BasicDocument::DefinitionList

      # Formula included within note.
      nodes :formula, BasicDocument::FormulaBlock

      # Sourcecode included within note.
      nodes :sourcecode, BasicDocument::SourcecodeBlock

      # Blockquote included within note.
      nodes :quotes, BasicDocument::QuoteBlock
    end
  end
end; end; end
