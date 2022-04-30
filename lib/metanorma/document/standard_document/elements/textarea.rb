# frozen_string_literal: true

require "metanorma/document/standard_document/elements/form_input"

module Metanorma; module Document; module StandardDocument
  # Input involving extended text. The value attribute is used instead of text area content
  class Textarea < FormInput
    register_element "textarea" do
      # Suggested number of rows for the input area
      attribute :rows, Integer

      # Suggested number of columns for the input area
      attribute :cols, Integer
    end
  end
end; end; end
