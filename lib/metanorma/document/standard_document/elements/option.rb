# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Option of a Select input
  class Option < Core::Node
    include Core::Node::Custom

    register_element do
      # Option is disabled
      nodes :disabled, TrueClass

      # Value associated with this option
      nodes :value, String

      # Display text associated with this option
      nodes :content, String
    end
  end
end; end; end
