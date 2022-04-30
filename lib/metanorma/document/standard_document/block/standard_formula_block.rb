# frozen_string_literal: true

require "basic_document/ancillaryblocks/formula_block"

module Metanorma; module Document; module StandardDocument
  class StandardFormulaBlock < BasicDocument::FormulaBlock
    register_element do
      # Override the numbering of this block in numbering.
      nodes :number, String
    end
  end
end; end; end
