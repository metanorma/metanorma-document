# frozen_string_literal: true

require "metanorma/document/standard_document/sections/standard_section"

module Metanorma; module Document; module StandardDocument
  # A hierarchical section containing other sections, within a _StandardDocument_.
  class StandardHierarchicalSection < StandardSection
    register_element do
      # Subclauses of the section.
      nodes :subsections, StandardSection
    end
  end
end; end; end
