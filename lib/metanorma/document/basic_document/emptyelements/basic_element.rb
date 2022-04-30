# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Container of inline content in BasicDocument.
  class BasicElement < Core::Node
    include Core::Node::Custom

    register_element do
      # Metadata of the contributor responsible for the action.
      nodes :contrib_metadata, ContributionElementMetadata
    end
  end
end; end; end
