# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Collection of definitions, constituting the core content of a DefinitionSection.
  class DefinitionCollection < Core::Node
    include Core::Node::Custom

    register_element do
      # Individual definition.
      nodes :definitions, BasicDocument::Definition
    end
  end
end; end; end
