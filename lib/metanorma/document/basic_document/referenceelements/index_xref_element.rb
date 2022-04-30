# frozen_string_literal: true

require "basic_document/referenceelements/reference_element"

module Metanorma; module Document; module BasicDocument
  # A reference to an index term, cross-referenced within an index as an
  # alternative index entry, either as a "see" or a "see also" cross-reference.
  # The text in the inline element is the primary index term to be be cross-referenced.
  class IndexXrefElement < ReferenceElement
    register_element do
      # The secondary index term to be be cross-referenced.
      attribute :secondary, String

      # The tertiary index term to be be cross-referenced.
      attribute :tertiary, String

      # The index term to be cross-referenced to.
      attribute :target, String

      # The cross-reference is to be treated as "see also" rather than as "see".
      attribute :also, TrueClass
    end
  end
end; end; end
