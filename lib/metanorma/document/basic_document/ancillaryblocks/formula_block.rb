# frozen_string_literal: true

require "basic_document/blocks/basic_block_no_notes"

module Metanorma; module Document; module BasicDocument
  # Block containing a mathematical expression or other formulas.
  class FormulaBlock < BasicBlockNoNotes
    register_element do
      # The content of the formula, as a mathematical expression.
      node :stem, StemElement

      # The block should be excluded from any automatic numbering of blocks of this class in the document.
      attribute :unnumbered, TrueClass

      # Define a subsequence for numbering of this block; e.g. if this block would be numbered
      # as 7, but it has a subsequence value of XYZ, this block, and all consecutive blocks
      # of the same class and with the same subsequence value, will be numbered consecutively
      # with the same number and in a subsequence: 7a, 7b, 7c etc.
      attribute :subsequence, String

      # Indication that the formula is to be labelled as an Inequality, if inequalities are differentiated
      # from equations.
      attribute :inequality, TrueClass

      # A definitions list defining any symbols used in the formula.
      node :definitions, DefinitionList
    end
  end
end; end; end
