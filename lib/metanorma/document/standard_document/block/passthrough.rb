# frozen_string_literal: true

require "metanorma/document/standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  # Wrapper around raw markup to be transferred into one or more nominated output formats
  # during processing.
  class Passthrough < StandardBlockNoNotes
    register_element do
      # Format of markup to be transferred.
      attribute :formats, String

      # Markup to be transferred.
      attribute :content, String
    end
  end
end; end; end
