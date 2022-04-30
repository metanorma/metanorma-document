# frozen_string_literal: true

require "metanorma/document/basic_document/blocks/basic_block_no_notes"

module Metanorma; module Document; module BasicDocument
  # Note block, modelled to consist only of paragraphs.
  class NoteBlock < BasicBlockNoNotes
    register_element "note" do
      # Note block content.
      nodes :content, ParagraphBlock
    end
  end
end; end; end
