# frozen_string_literal: true

require "basic_document/change/node_change"

module Metanorma; module Document; module BasicDocument
  # Specification of moving a particular node in a BasicDocument
  # to another location within the same BasicDocument.
  class NodeMove < NodeChange
  end
end; end; end
