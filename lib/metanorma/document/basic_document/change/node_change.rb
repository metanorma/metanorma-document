# frozen_string_literal: true

require "metanorma/document/basic_document/change/change"

module Metanorma; module Document; module BasicDocument
  # Possible actions that involve
  # modification of data elements at the node level within a
  # BasicDocument. Add/remove node; Move node.
  class NodeChange < Change
    register_element
  end
end; end; end
