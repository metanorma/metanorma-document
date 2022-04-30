# frozen_string_literal: true

require "basic_document/referenceelements/reference_to_id_element"

module Metanorma; module Document; module StandardDocument
  # Label associated with form input element
  class Label < BasicDocument::ReferenceToIdElement
    register_element "label"
  end
end; end; end
