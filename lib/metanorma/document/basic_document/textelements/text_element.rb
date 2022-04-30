# frozen_string_literal: true

require "metanorma/document/basic_document/emptyelements/basic_element"

module Metanorma; module Document; module BasicDocument
  # Inline element containing text and associated formatting information,
  # but which does not contain any associated identifiers or references to identifiers.
  class TextElement < BasicElement
    register_element do
      # Content of the Text Element. May recursively contain other Text Elements.
      node :content, TextElementType
    end
  end
end; end; end
