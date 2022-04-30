# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Formally defined concept used in a _StandardDocument_, aligned to a definition.
  # That concept may be defined as a term within the current document, or it may
  # be defined externally.
  class Concept < Core::Node
    include Core::Node::Custom

    register_element do
      # Render the term in the concept in italics.
      nodes :ital, TrueClass

      # Render a reference to a definition for the concept.
      nodes :ref, TrueClass

      # Hyperlink the mention of the term to the definition for the concept.
      nodes :linkmention, TrueClass

      # Hyperlink the reference for the term to the definition for the concept.
      nodes :linkref, TrueClass

      # The canonical name of the concept being defined.
      nodes :refterm, String

      # The rendering to be used for the concept.
      nodes :renderterm, String

      # Link to a definition of the term in an element of the current document.
      nodes :xref, BasicDocument::ReferenceToIdElement

      # Link to a definition of the term in a bibliographic entry.
      nodes :eref, BasicDocument::ReferenceToCitationElement

      # Link to a definition of the term in a termbase.
      nodes :termref, ReferenceToTermbase
    end
  end
end; end; end
