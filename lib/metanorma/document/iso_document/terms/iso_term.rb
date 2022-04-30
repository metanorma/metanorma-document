# frozen_string_literal: true

require "metanorma/document/standard_document/terms/term"

module Metanorma; module Document; module IsoDocument
  # Term subclause specific to ISO/IEC documents.
  class IsoTerm < StandardDocument::Term
    register_element do
      # ISO/IEC documents have only a single preferred term name per term subclause.
      node :preferred, BasicDocument::LocalizedString

      # ISO/IEC documents do not use related terms.
      nodes :related, StandardDocument::RelatedTerm

      # Terms nested within terms, under systematic term ordering.
      nodes :term, IsoTerm
    end
  end
end; end; end
