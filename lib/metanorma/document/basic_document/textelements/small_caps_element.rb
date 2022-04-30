# frozen_string_literal: true

require "basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Small caps text.
  class SmallCapsElement < TextElement
    register_element "smallcap"
  end
end; end; end
