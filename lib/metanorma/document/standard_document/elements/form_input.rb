# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Input element for forms, associated with name/value pair to be submitted
  class FormInput < Core::Node
    include Core::Node::Custom

    register_element do
      # Identifier of input element
      nodes :id, String

      # Name of value of input element to be submitted
      nodes :name, String

      # Preset or default of value of input element to be submitted
      nodes :value, String
    end
  end
end; end; end
