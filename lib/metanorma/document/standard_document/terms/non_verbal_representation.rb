# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Non-verbal representation of the term.
  class NonVerbalRepresentation < Core::Node
    include Core::Node::Custom

    register_element "non-verbal-representation" do
      # Figure representation of the term.
      nodes :figure, BasicDocument::FigureBlock

      # Figure representation of the term.
      nodes :formula, BasicDocument::FormulaBlock

      # Figure representation of the term.
      nodes :table, BasicDocument::TableBlock

      # Bibliographic references for this designation of the managed term.
      nodes :sources, TermSource
    end
  end
end; end; end
