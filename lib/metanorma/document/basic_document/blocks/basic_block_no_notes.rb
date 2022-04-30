# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Base class of blocks for a BasicDocument, omitting notes.
  class BasicBlockNoNotes < Core::Node
    include Core::Node::Custom

    register_element do
      # Identifier for the block, to be used for cross-references.
      attribute :id, String

      # Attribution of the block to a specific contributor, to be used in change management of documents.
      nodes :contrib_metadata, ContributionElementMetadata
    end
  end
end; end; end
