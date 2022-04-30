# frozen_string_literal: true

require "metanorma/document/standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  # A floating title, outside of the clause hierarchy
  class FloatingTitle < StandardBlockNoNotes
    register_element do
      # The depth of the floating title in the clause hierarchy: which level heading it should be presented
      # as
      attribute :depth, Integer
    end
  end
end; end; end
