# frozen_string_literal: true

require "metanorma/document/basic_document/textelements/text_element"

module Metanorma; module Document; module StandardDocument
  # Indication of text added through editorial intervention.
  class Add < BasicDocument::TextElement
    register_element
  end
end; end; end
