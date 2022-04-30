# frozen_string_literal: true

require "metanorma/document/basic_document/sections/basic_section"

module Metanorma; module Document; module BasicDocument
  # Sections: groups of blocks within text, which can also contain other sections.
  class HierarchicalSection < BasicSection
    register_element do
      # Sections contained within the current section. The relation is recursive,
      # so the hierarchical arrangement of sections can be arbitrarily deep.
      nodes :subsections, HierarchicalSection
    end
  end
end; end; end
