# frozen_string_literal: true

require "metanorma/document/basic_document/referenceelements/reference_element"

module Metanorma; module Document; module BasicDocument
  # A reference to an external document or resource.
  class ReferenceToLinkElement < ReferenceElement
    register_element do
      # The location or online identifier of the external document or resource.
      attribute :target, Uri
    end
  end
end; end; end
