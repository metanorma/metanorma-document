# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Blocks
      # Note block, modelled to consist only of paragraphs.
      class NoteBlock < Metanorma::BasicDocument::Blocks::BasicBlockNoNotes
        attribute :content,
                  Metanorma::BasicDocument::Paragraphs::ParagraphBlock, collection: true

        xml do
          element "note"
          map_element "content", to: :content
        end
      end
    end
  end
end
