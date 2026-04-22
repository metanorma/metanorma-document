# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Blocks
      autoload :BasicBlock, "#{__dir__}/blocks/basic_block"
      autoload :BasicBlockNoNotes,
               "#{__dir__}/blocks/basic_block_no_notes"
      autoload :NoteBlock, "#{__dir__}/blocks/note_block"
    end
  end
end
