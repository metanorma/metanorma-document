# frozen_string_literal: true

require "standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  class StandardBlock < StandardBlockNoNotes
    register_element do
      # Do not permit a page break between the lines of the block in paged media.
      attribute :keep_lines_together, TrueClass

      # Keep this block on the same page as the following block in paged media.
      attribute :keep_with_next, TrueClass
    end
  end
end; end; end
