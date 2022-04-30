# frozen_string_literal: true

require "basic_document/paragraphs/paragraph_block"

module Metanorma; module Document; module BasicDocument
  # A paragraph which may also contain footnotes.
  # While most paragraphs in a document can contain footnotes, the distinction is necessary, as
  # footnotes are not appropriate for all instances of paragraph content in a document (e.g. sourcecode
  # annotations).
  class ParagraphWithFootnote < ParagraphBlock
    register_element do
      # Footnotes contained in the paragraph.
      nodes :footnotes, BasicObject # But actually: ReferenceToldWithParagraphElement
    end
  end
end; end; end
