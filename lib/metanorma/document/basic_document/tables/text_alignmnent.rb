# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Horizontal textual alignment of the cell against the underlying table grid.
  class TextAlignmnent < Core::Node::Enum
    # Left-aligned.
    LEFT = new("left")

    # Center-aligned.
    CENTER = new("center")

    # Right-aligned.
    RIGHT = new("right")
  end
end; end; end
