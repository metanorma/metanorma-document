# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Block of textual content in BasicDocument.
  class BasicBlock < Core::Node
    include Core::Node::Custom

    register_element do
      # Notes whose scope is the current block.
      nodes :notes, NoteBlock
    end
  end
end; end; end
