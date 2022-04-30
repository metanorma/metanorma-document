# frozen_string_literal: true

require "metanorma/document/standard_document/sections/clause_section"

module Metanorma; module Document; module StandardDocument
  # Term sections (`TermsSection`) give elaborated definitions of terms used in
  # a standardization document.
  #
  # NOTE: The `TermsSection` definition fully aligns with the structure
  # and requirements of the "Terms and definition" section given in
  # ISO/IEC DIR 2.
  class TermsSection < ClauseSection
    register_element do
      # Terms defined in the term section.
      node :terms, TermCollection
    end
  end
end; end; end
