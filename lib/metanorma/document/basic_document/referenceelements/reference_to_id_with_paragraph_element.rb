# frozen_string_literal: true

require "metanorma/document/basic_document/referenceelements/reference_to_id_element"

module Metanorma; module Document; module BasicDocument
  # Inline reference to a paragraph or paragraphs: element combining the reference and the referenced
  # content in the one element.
  class ReferenceToIdWithParagraphElement < ReferenceToIdElement
    register_element do
      # The paragraph or paragraphs referenced in this element.
      nodes :content, ParagraphBlock
    end
  end
end; end; end
