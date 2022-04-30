# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Textual content constituting a basic building block of a table.
  class TableCell < Core::Node
    include Core::Node::Custom

    register_element do
      # Number of columns in the underlying table grid which the cell spans.
      nodes :colspan, Integer

      # Number of rows in the underlying table grid which the cell spans.
      nodes :rowspan, Integer

      # Horizontal textual alignment of the cell against the underlying table grid.
      nodes :align, TextAlignmnent

      # Vertical alignment of the cell against the underlying table grid.
      nodes :valign, VerticalAlignmnent
    end
  end
end; end; end
