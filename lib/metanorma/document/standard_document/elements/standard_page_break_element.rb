# frozen_string_literal: true

require "basic_document/emptyelements/page_break_element"

module Metanorma; module Document; module StandardDocument
  class StandardPageBreakElement < BasicDocument::PageBreakElement
    register_element do
      # Orientation of pages following this page break, until the next page break that
      # gives an explicit page orientation.
      nodes :orientation, OrientationType
    end
  end
end; end; end
