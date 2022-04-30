# frozen_string_literal: true

require "metanorma/document/basic_document/tables/table_cell"

module Metanorma; module Document; module BasicDocument
  # Table cells composed of inline elements, and therefore corresponding to a single block.
  class TextTableCell < TableCell
    register_element "td" do
      # Content of the Text Table Cell.
      nodes :content, TextElement
    end
  end
end; end; end
