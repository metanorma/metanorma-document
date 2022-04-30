# frozen_string_literal: true

require "metanorma/document/basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Strong text. Corresponds to HTML `strong`, `b`.
  class StrongElement < TextElement
    register_element "strong"
  end
end; end; end
