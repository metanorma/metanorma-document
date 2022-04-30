# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Verbal expression of the term.
  class VerbalExpression < Core::Node
    include Core::Node::Custom

    register_element do
      # Paragraph in term definition.
      nodes :paragraph, BasicDocument::ParagraphBlock

      # Ordered list in term definition.
      nodes :ol, BasicDocument::OrderedList

      # Unordered list in term definition.
      nodes :ul, BasicDocument::UnorderedList

      # Definition list in term definition.
      nodes :dl, BasicDocument::DefinitionList
    end
  end
end; end; end
