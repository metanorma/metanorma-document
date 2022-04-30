# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The definition of a term applied in the current
  # document.
  class TermDefinition < Core::Node
    include Core::Node::Custom

    register_element "definition" do
      # The content of the definition of the term applied in the current
      # document.
      node :verbalexpression, VerbalExpression

      # Non-verbal representation of the term applied in the current
      # document.
      node :nonverbalrepresentation, NonVerbalRepresentation

      # Zero or more bibliographical sources for this definition of the term. These
      # include the `origin` of the term, which is its bibliographical
      # citation (as defined in Relaton); the `status` of the
      # definition (whether `identical` to the definition given in the
      # origin cited, or `modified`); and, if the definition is modified, a
      # description of the `modification` to the definition applied for
      # this document.
      nodes :source, TermSource
    end
  end
end; end; end
