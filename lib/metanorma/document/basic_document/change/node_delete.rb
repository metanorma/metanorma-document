# frozen_string_literal: true

require "basic_document/change/node_change"

module Metanorma; module Document; module BasicDocument
  # Specification of the deletion of a data node in a BasicDocument.
  class NodeDelete < NodeChange
    register_element do
      # A string that contains the hash value of the node to be deleted for verification purposes.
      attribute :hash_value, String
    end
  end
end; end; end
