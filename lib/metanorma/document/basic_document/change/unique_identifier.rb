# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Identifier used to uniquely identify a BasicDocument.
  class UniqueIdentifier < Core::Node
    include Core::Node::Custom

    register_element do
      # A string that uniquely identifies a BasicDocument.
      attribute :value, String
    end
  end
end; end; end
