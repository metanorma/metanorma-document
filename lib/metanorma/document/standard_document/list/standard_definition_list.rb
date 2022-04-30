# frozen_string_literal: true

require "basic_document/lists/definition_list"

module Metanorma; module Document; module StandardDocument
  class StandardDefinitionList < BasicDocument::DefinitionList
    register_element do
      # Do not permit a page break between the lines of the block in paged media.
      attribute :keep_lines_together, TrueClass

      # Keep this block on the same page as the following block in paged media.
      attribute :keep_with_next, TrueClass

      # This definition list is the key of a figure or formula.
      attribute :key, TrueClass
    end
  end
end; end; end
