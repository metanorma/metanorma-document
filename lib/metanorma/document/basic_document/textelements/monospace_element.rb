# frozen_string_literal: true

require "basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Monospace text. Corresponds to HTML `tt`, `code`.
  class MonospaceElement < TextElement
    register_element %w[tt code]
  end
end; end; end
