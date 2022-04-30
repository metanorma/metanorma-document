# frozen_string_literal: true

require "metanorma/document/basic_document/referenceelements/reference_element"

module Metanorma; module Document; module BasicDocument
  # An external reference to a bibliographic entity.
  class ReferenceToCitationElement < ReferenceElement
    register_element do
      # Whether the reference is to be treated as normative or informative, particularly in the context of
      # normative documents such as standards.
      attribute :normative, TrueClass

      # Form that the bibliographic citation should take when it is rendered.
      nodes :cite_as, TextElement
    end
  end
end; end; end
