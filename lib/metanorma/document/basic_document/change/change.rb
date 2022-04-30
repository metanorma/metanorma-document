# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Specification of an update action to be performed incrementally on an element within a
  # BasicDocument.
  class Change < Core::Node
    include Core::Node::Custom

    register_element do
      # The element that this action should be applied to.
      node :target, ReferenceToIdElement

      # A unique identifier of this change.
      node :identifier, UniqueIdentifier

      # One or more unique identifiers of _Change_ objects, that this change is supposed to follow after.
      nodes :parent_identifier, UniqueIdentifier

      # Metadata of the contributor responsible for the action.
      nodes :contrib_metadata, ContributionElementMetadata
    end
  end
end; end; end
