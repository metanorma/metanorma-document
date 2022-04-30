# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  class StandardDefinitionTerm < Core::Node
    include Core::Node::Custom

    register_element do
      # Optional identifier for definition term (enabling crossreferencing of definitions).
      attribute :id, String

      # Entry being defined in the definition.
      nodes :content, BasicDocument::TextElement
    end
  end
end; end; end
