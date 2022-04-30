# frozen_string_literal: true

require "basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Superscript text. Corresponds to HTML `sup`.
  class SuperscriptElement < TextElement
    register_element
  end
end; end; end