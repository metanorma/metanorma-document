# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Base class of blocks for a BasicDocument, omitting notes.
  class BasicBlockNoNotes < Core::Node
    include Core::Node::Custom
  end
end; end; end
