# frozen_string_literal: true

require "standard_document/elements/form_input"

module Metanorma; module Document; module StandardDocument
  # Input involving extended text. The value attribute is used instead of text area content
  class Textarea < FormInput
    register_element do
      # Suggested number of rows for the input area
      nodes :rows, Integer

      # Suggested number of columns for the input area
      nodes :cols, Integer
    end
  end
end; end; end
