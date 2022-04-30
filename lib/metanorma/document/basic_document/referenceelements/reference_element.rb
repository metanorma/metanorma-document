# frozen_string_literal: true

require "basic_document/emptyelements/basic_element"

module Metanorma; module Document; module BasicDocument
  # Inline element, which references an identifier of a document, a block in a document, or an element
  # in a document.
  class ReferenceElement < BasicElement
    register_element do
      # The type of Reference Element, prescribing how it is to be rendered.
      attribute :type, ReferenceFormat

      # The textual content of the element. The `text` is what we wish to show the link as (e.g., the
      # "content" of `<xx>my link text</xx>`)
      node :text, BasicElement

      # Alternate text, used for accessibility.
      attribute :alt, String
    end
  end
end; end; end
