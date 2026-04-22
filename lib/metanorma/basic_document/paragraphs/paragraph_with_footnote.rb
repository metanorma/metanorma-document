# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Paragraphs
      # A paragraph which may also contain footnotes.
      # While most paragraphs in a document can contain footnotes, the distinction is necessary, as
      # footnotes are not appropriate for all instances of paragraph content in a document (e.g. sourcecode
      # annotations).
      class ParagraphWithFootnote < Metanorma::BasicDocument::Paragraphs::ParagraphBlock
        # Footnotes contained in the paragraph.
        attribute :footnotes, BasicObject, collection: true # But actually: ReferenceToldWithParagraphElement

        xml do
          element "paragraph-with-footnote"
          map_element "footnotes", to: :footnotes
        end
      end
    end
  end
end
