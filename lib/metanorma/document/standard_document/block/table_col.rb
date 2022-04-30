# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  class TableCol < Core::Node
    include Core::Node::Custom

    register_element do
      # The width of an individual table column.
      attribute :width, String
    end
  end
end; end; end
