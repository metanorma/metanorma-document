# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module AncillaryBlocks
      autoload :ExampleBlock, "#{__dir__}/ancillary_blocks/example_block"
      autoload :FigureBlock, "#{__dir__}/ancillary_blocks/figure_block"
      autoload :FormulaBlock, "#{__dir__}/ancillary_blocks/formula_block"
      autoload :LiteralBlock, "#{__dir__}/ancillary_blocks/literal_block"
      autoload :SourcecodeBlock,
               "#{__dir__}/ancillary_blocks/sourcecode_block"
      autoload :Subfigure, "#{__dir__}/ancillary_blocks/subfigure"
    end
  end
end
