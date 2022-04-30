# frozen_string_literal: true

require "basic_document/blocks/basic_block_no_notes"

module Metanorma; module Document; module StandardDocument
  class StandardBlockNoNotes < BasicDocument::BasicBlockNoNotes
    register_element do
      # Non-unique identifier within document. Used to align two blocks in different languages in a
      # multilingual document.
      nodes :tag, String

      # Specification of how a block element may be rendered in a multilingual document.
      nodes :multilingual_rendering, MultilingualRenderingType
    end
  end
end; end; end
