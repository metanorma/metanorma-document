# frozen_string_literal: true

require "basic_document/tables/table_cell"

module Metanorma; module Document; module BasicDocument
  # Table cells composed of multiple paragraphs.
  class ParagraphTableCell < TableCell
    register_element do
      # Content of the Paragraph Table Cell.
      nodes :content, ParagraphWithFootnote
    end
  end
end; end; end
