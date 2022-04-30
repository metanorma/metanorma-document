# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Vertical alignment of the cell against the underlying table grid.
  class VerticalAlignmnent < Core::Node::Enum
    # Aligned against the top of the table row.
    TOP = new("top")

    # Aligned against the middle of the table row.
    MIDDLE = new("middle")

    # Aligned against the bottom of the table row.
    BOTTOM = new("bottom")

    # The first line of text of such cells in a table row is aligned to a common vertical baseline.
    BASELINE = new("baseline")
  end
end; end; end
