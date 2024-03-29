# frozen_string_literal: true

require "metanorma/document/basic_document/textelements/text_element"

module Metanorma; module Document; module StandardDocument
  # Indication of text deleted through editorial intervention.
  class Del < BasicDocument::TextElement
    register_element "del"
  end
end; end; end
