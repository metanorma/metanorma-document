# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Term related to the current term.
  class RelatedTerm < Core::Node
    include Core::Node::Custom

    register_element do
      # Type of relation of term applicable.
      attribute :type, RelatedTermType

      # Label of term related to the current term.
      node :preferred, Designation

      # Link to a definition of the term in an element of the current document.
      nodes :xref, BasicDocument::ReferenceToIdElement

      # Link to a definition of the term in a bibliographic entry.
      nodes :eref, BasicDocument::ReferenceToCitationElement

      # Link to a definition of the term in a termbase.
      nodes :termref, ReferenceToTermbase
    end
  end
end; end; end
