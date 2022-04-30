# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Formally defined concept used in a _StandardDocument_, aligned to a definition.
  # That concept may be defined as a term within the current document, or it may
  # be defined externally.
  class Concept < Core::Node
    include Core::Node::Custom

    register_element "concept" do
      # Render the term in the concept in italics.
      attribute :ital, TrueClass

      # Render a reference to a definition for the concept.
      attribute :ref, TrueClass

      # Hyperlink the mention of the term to the definition for the concept.
      attribute :linkmention, TrueClass

      # Hyperlink the reference for the term to the definition for the concept.
      attribute :linkref, TrueClass

      # The canonical name of the concept being defined.
      text :refterm, String

      # The rendering to be used for the concept.
      text :renderterm, String

      # Link to a definition of the term in an element of the current document.
      node :xref, BasicDocument::ReferenceToIdElement

      # Link to a definition of the term in a bibliographic entry.
      node :eref, BasicDocument::ReferenceToCitationElement

      # Link to a definition of the term in a termbase.
      node :termref, ReferenceToTermbase
    end
  end
end; end; end
