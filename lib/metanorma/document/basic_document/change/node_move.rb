# frozen_string_literal: true

require "metanorma/document/basic_document/change/node_change"

module Metanorma; module Document; module BasicDocument
  # Specification of moving a particular node in a BasicDocument
  # to another location within the same BasicDocument.
  class NodeMove < NodeChange
    register_element do
      # Indicates the position of the node's parent.
      # While this seems redundant to the `target` attribute inherited from the _Change_ model,
      # it is useful for verifying that the location has not changed.
      node :position_old, ReferenceToIdElement

      # Indicates the new parent or sibling of the node.
      node :position_new, ReferenceToIdElement
    end
  end
end; end; end
