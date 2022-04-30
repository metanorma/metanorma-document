# frozen_string_literal: true

require "basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Strikethrough text. Corresponds to HTML 4 `s`.
  class StrikeElement < TextElement
    register_element "strike"
  end
end; end; end
