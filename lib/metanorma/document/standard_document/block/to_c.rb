# frozen_string_literal: true

require "metanorma/document/standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  # Table of contents, represented as a list of crossreferences, each with textual content.
  class ToC < StandardBlockNoNotes
    register_element do
      # List of crossreferences.
      node :list, StandardUnorderedList
    end
  end
end; end; end
