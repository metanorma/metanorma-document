# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module AncillaryBlocks
      # Block containing a mathematical expression or other formulas.
      class FormulaBlock < Metanorma::BasicDocument::Blocks::BasicBlockNoNotes
        # The content of the formula, as a mathematical expression.
        attribute :stem, Metanorma::BasicDocument::TextElements::StemElement

        # The block should be excluded from any automatic numbering of blocks of this class in the document.
        attribute :unnumbered, :boolean

        # Define a subsequence for numbering of this block; e.g. if this block would be numbered
        # as 7, but it has a subsequence value of XYZ, this block, and all consecutive blocks
        # of the same class and with the same subsequence value, will be numbered consecutively
        # with the same number and in a subsequence: 7a, 7b, 7c etc.
        attribute :subsequence, :string

        # Indication that the formula is to be labelled as an Inequality, if inequalities are differentiated
        # from equations.
        attribute :inequality, :boolean

        # A definitions list defining any symbols used in the formula.
        attribute :definitions, Metanorma::BasicDocument::Lists::DefinitionList

        xml do
          element "formula"
          map_element "stem", to: :stem
          map_attribute "unnumbered", to: :unnumbered
          map_attribute "subsequence", to: :subsequence
          map_attribute "inequality", to: :inequality
          map_element "definitions", to: :definitions
        end
      end
    end
  end
end
