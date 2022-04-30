# frozen_string_literal: true

require "standard_document/terms/term_collection"

module Metanorma; module Document; module IsoDocument
  # Term collection specific to ISO/IEC documents.
  class IsoTermCollection < StandardDocument::TermCollection
    register_element do
      # Term subclauses specific to ISO/IEC documents.
      nodes :terms, IsoTerm
    end
  end
end; end; end
