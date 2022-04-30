# frozen_string_literal: true

require "standard_document/sections/standard_hierarchical_section"

module Metanorma; module Document; module StandardDocument
  # An unnumbered clause, outside the main body of text of a _StandardDocument_.
  class StandardContentSection < StandardHierarchicalSection
    register_element do
      # The type of content provided in the section, used as a semantic classification.
      nodes :type, String
    end
  end
end; end; end
