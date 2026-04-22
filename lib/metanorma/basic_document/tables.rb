# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Tables
      autoload :ParagraphTableCell,
               "#{__dir__}/tables/paragraph_table_cell"
      autoload :TableBlock, "#{__dir__}/tables/table_block"
      autoload :TableCell, "#{__dir__}/tables/table_cell"
      autoload :TextAlignment, "#{__dir__}/tables/text_alignment"
      autoload :TextTableCell, "#{__dir__}/tables/text_table_cell"
      autoload :TextTableRow, "#{__dir__}/tables/text_table_row"
      autoload :VerticalAlignment, "#{__dir__}/tables/vertical_alignment"
    end
  end
end
