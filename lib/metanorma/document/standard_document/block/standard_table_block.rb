# frozen_string_literal: true

require "basic_document/tables/table_block"

module Metanorma; module Document; module StandardDocument
  class StandardTableBlock < BasicDocument::TableBlock
    register_element do
      # Width of the table block in rendering.
      nodes :width, String

      # Override the numbering of this block in numbering.
      nodes :number, String

      # The widths of the columns in the table.
      nodes :colgroup, TableCol
    end
  end
end; end; end
