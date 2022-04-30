# frozen_string_literal: true

require "basic_document/referenceelements/reference_element"

module Metanorma; module Document; module BasicDocument
  # A reference to an index term, cross-referenced within an index as an
  # alternative index entry, either as a "see" or a "see also" cross-reference.
  # The text in the inline element is the primary index term to be be cross-referenced.
  class IndexXrefElement < ReferenceElement
  end
end; end; end
