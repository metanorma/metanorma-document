# frozen_string_literal: true

require "basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Subscript text. Corresponds to HTML `sub`.
  class SubscriptElement < TextElement
    register_element
  end
end; end; end
