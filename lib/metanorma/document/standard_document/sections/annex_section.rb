# frozen_string_literal: true

require "standard_document/sections/standard_section"

module Metanorma; module Document; module StandardDocument
  # Section of document constituting an annex or appendix.
  class AnnexSection < StandardSection
    register_element do
      # Subsections of the annex. Added explicitly because AnnexSection permits hanging paragraphs
      # (top-level blocks are included in the section alongside subsections).
      nodes :subsections, ClauseSection
    end
  end
end; end; end
