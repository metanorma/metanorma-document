# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # A collection of _Change_ data, specifying the document they should be applied to.
  class ChangeSet < Core::Node
    include Core::Node::Custom

    register_element do
      # The set of _Change_ data.
      nodes :changes, Change

      # The unique identifier that identifies the BasicDocument.
      node :document_identifier, UniqueIdentifier
    end
  end
end; end; end
