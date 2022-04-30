# frozen_string_literal: true

require "basic_document/referenceelements/reference_element"

module Metanorma; module Document; module BasicDocument
  # An internal reference to an element of the current document.
  class ReferenceToIdElement < ReferenceElement
    register_element do
      # The identifier of a section, block or inline element referenced.
      node :target, IdElement
    end
  end
end; end; end
