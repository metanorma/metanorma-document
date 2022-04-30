# frozen_string_literal: true

require "standard_document/sections/annex_section"

module Metanorma; module Document; module IsoDocument
  # Annex appearing in ISO/IEC document.
  class IsoAnnexSection < StandardDocument::AnnexSection
    register_element do
      # Appendixes to annex.
      nodes :appendix, StandardDocument::ClauseSection
    end
  end
end; end; end
