# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Edition of a bibliographic item.
  class Edition < Core::Node
    include Core::Node::Custom

    register_element do
      # Number of edition.
      #
      # NOTE: The number attribute can be used to represent the numeric equivalent
      # of the edition string.
      nodes :number, String

      # Formatted edition string for human reading.
      node :content, BasicDocument::FormattedString
    end
  end
end; end; end
