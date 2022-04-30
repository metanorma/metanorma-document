# frozen_string_literal: true

require "metanorma/document/basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Emphasised text. Corresponds to HTML `em`, `i`.
  class EmphasisElement < TextElement
    register_element
  end
end; end; end
