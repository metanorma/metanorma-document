# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Sequence of cells to be displayed as a row in a table.
  class TextTableRow < Core::Node
    include Core::Node::Custom

    register_element "tr" do
      # Data cells in a table row.
      nodes :td, TableCell

      # Header cells in a table row.
      nodes :th, TableCell
    end
  end
end; end; end
