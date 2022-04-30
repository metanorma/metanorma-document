# frozen_string_literal: true

require "metanorma/document/standard_document/elements/form_input"

module Metanorma; module Document; module StandardDocument
  # Indication of text added through editorial intervention.
  class Input < FormInput
    register_element "input" do
      # Type of input element
      attribute :type, InputType

      # Input element is checkbox, and has checked value
      attribute :checked, TrueClass

      # Input element is disabled
      attribute :disabled, TrueClass

      # Input element is read-only
      attribute :readonly, TrueClass

      # Maximum length of input in characters, for character input
      attribute :maxlength, Integer

      # Minimum length of input in characters, for character input
      attribute :minlength, Integer
    end
  end
end; end; end
