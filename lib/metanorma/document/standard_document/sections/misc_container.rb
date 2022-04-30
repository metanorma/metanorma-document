# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Extension point for extraneous elements that need to be added to standards document
  # from other schemas, e.g. UnitsML.
  class MiscContainer < Core::Node
    include Core::Node::Custom

    register_element do
      nodes :element, Object
    end
  end
end; end; end
