# frozen_string_literal: true

require "metanorma/document/basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Mathematically formatted text.
  class StemElement < TextElement
    register_element "stem" do
      # The notation used to mathematically format the text.
      attribute :stem_type, StemType, xml_attribute: "type"

      # The content of the mathematically formatted text.
      node :stem_value, StemValue
    end
  end
end; end; end
