# frozen_string_literal: true

require "metanorma/document/standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  # Input form, for use under HTML.
  class Form < StandardBlockNoNotes
    register_element do
      # Identifier of the input form block
      attribute :id, String

      # Name of the input form block
      attribute :name, String

      # Action to be taken on submission of the input form
      attribute :action, String

      # Class of input form.
      attribute :class, String

      # Text element content of the form
      nodes :text, BasicDocument::TextElement

      # Form input elements
      nodes :input, FormInput

      # Form input labels
      nodes :label, Label
    end
  end
end; end; end
