# frozen_string_literal: true

require "basic_document/referenceelements/reference_element"

module Metanorma; module Document; module StandardDocument
  # Cross-reference to a term.
  class ReferenceToTerm < BasicDocument::ReferenceElement
    register_element do
      # Identifier of the source where the term is defined.
      node :source, BasicObject # But actually: ReferenceToTermSource

      # Text to display for the cross-reference to the term.
      nodes :term, String
    end
  end
end; end; end
