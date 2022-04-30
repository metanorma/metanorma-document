# frozen_string_literal: true

require "standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  # Wrapper around raw markup to be transferred into one or more nominated output formats
  # during processing.
  class Passthrough < StandardBlockNoNotes
  end
end; end; end
