# frozen_string_literal: true

require "metanorma/document/basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Underlined text. Corresponds to HTML 4 `u`.
  class UnderlineElement < TextElement
    register_element "underline"
  end
end; end; end
