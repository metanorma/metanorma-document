# frozen_string_literal: true

require "basic_document/referenceelements/reference_to_id_with_paragraph_element"

module Metanorma; module Document; module BasicDocument
  # Inline reference to a paragraph or paragraphs, appearing as a footnote.
  class Footnote < ReferenceToIdWithParagraphElement
    register_element do
      node :type, BasicObject # But actually: footnote
    end
  end
end; end; end
