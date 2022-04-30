# frozen_string_literal: true

require "basic_document/lists/definition"

module Metanorma; module Document; module StandardDocument
  class StandardDefinition < BasicDocument::Definition
    register_element do
      # Entry being defined in the definition.
      nodes :item, StandardDefinitionTerm
    end
  end
end; end; end
