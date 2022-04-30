# frozen_string_literal: true

require "metanorma/document/standard_document/sections/clause_section"

module Metanorma; module Document; module IsoDocument
  # Clause appearing in an ISO/IEC Amendment or Technical Corrigendum document.
  class IsoAmendmentClause < StandardDocument::ClauseSection
    register_element do
      # Block expressing a machine-readable change in a document.
      node :amend, StandardDocument::AmendBlock
    end
  end
end; end; end
