# frozen_string_literal: true

require "standard_document/elements/form_input"

module Metanorma; module Document; module StandardDocument
  # Indication of text added through editorial intervention.
  class Input < FormInput
    register_element do
      # Type of input element
      attribute :type, InputType

      # Input element is checkbox, and has checked value
      nodes :checked, TrueClass

      # Input element is disabled
      nodes :disabled, TrueClass

      # Input element is read-only
      nodes :readonly, TrueClass

      # Maximum length of input in characters, for character input
      nodes :maxlength, Integer

      # Minimum length of input in characters, for character input
      nodes :minlength, Integer
    end
  end
end; end; end
