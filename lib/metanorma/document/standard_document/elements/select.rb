# frozen_string_literal: true

require "standard_document/elements/form_input"

module Metanorma; module Document; module StandardDocument
  # Input allowing the selection of a value from a list of values. The value attribute is used instead
  # of a selected
  # attribute on a component option
  class Select < FormInput
    register_element "select" do
      # Input is disabled
      attribute :disabled, TrueClass

      # Input can return multiple option values
      attribute :multiple, TrueClass

      # Suggested number of options to display
      attribute :size, Integer

      # Options to select from as value of the input
      nodes :option, Option
    end
  end
end; end; end
