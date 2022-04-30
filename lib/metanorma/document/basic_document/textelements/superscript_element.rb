# frozen_string_literal: true

require "metanorma/document/basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Superscript text. Corresponds to HTML `sup`.
  class SuperscriptElement < TextElement
    register_element "sup"
  end
end; end; end
