# frozen_string_literal: true

require "standard_document/sections/clause_section"

module Metanorma; module Document; module StandardDocument
  # Clauses in which all textual content belongs in a strict clause hierarchy. such that no blocks of
  # text
  # are siblings to subclauses.
  class ClauseHierarchicalSection < ClauseSection
    register_element do
      # Subclauses which are mutually exclusive with text content.
      nodes :subsections, ClauseHierarchicalSection
    end
  end
end; end; end
