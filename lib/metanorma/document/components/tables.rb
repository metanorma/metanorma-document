# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        autoload :HeaderTableCell, "#{__dir__}/tables/header_table_cell"
        autoload :ParagraphTableCell, "#{__dir__}/tables/paragraph_table_cell"
        autoload :TableBlock, "#{__dir__}/tables/table_block"
        autoload :TableCell, "#{__dir__}/tables/table_cell"
        autoload :TableHeadSection, "#{__dir__}/tables/table_section"
        autoload :TableBodySection, "#{__dir__}/tables/table_section"
        autoload :TableFootSection, "#{__dir__}/tables/table_section"
        autoload :TableSection, "#{__dir__}/tables/table_section"
        autoload :TextAlignment, "#{__dir__}/tables/text_alignment"
        autoload :TextTableCell, "#{__dir__}/tables/text_table_cell"
        autoload :TextTableRow, "#{__dir__}/tables/text_table_row"
        autoload :VerticalAlignment, "#{__dir__}/tables/vertical_alignment"
      end
    end
  end
end
