# frozen_string_literal: true

require "metanorma/document/basic_document/ancillaryblocks/figure_block"

module Metanorma; module Document; module StandardDocument
  class StandardFigureBlock < BasicDocument::FigureBlock
    register_element do
      # Override the numbering of this block in numbering.
      attribute :number, String
    end
  end
end; end; end
