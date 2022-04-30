# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Option of a Select input
  class Option < Core::Node
    include Core::Node::Custom

    register_element "option" do
      # Option is disabled
      attribute :disabled, TrueClass

      # Value associated with this option
      attribute :value, String

      # Display text associated with this option
      text :content, String
    end
  end
end; end; end
