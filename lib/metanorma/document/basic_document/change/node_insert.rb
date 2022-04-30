# frozen_string_literal: true

require "basic_document/change/node_change"

module Metanorma; module Document; module BasicDocument
  # Specification of the insertion
  # of a data node in a BasicDocument.
  class NodeInsert < NodeChange
    register_element do
      # A data element conforming to _BasicElement_ to be inserted into the specified BasicDocument.
      node :content, BasicElement
    end
  end
end; end; end
