# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module MultiParagraph
      # Block composed of multiple paragraphs.
      class ParagraphsBlock < Metanorma::BasicDocument::Paragraphs::ParagraphWithFootnote
        # The paragraphs constituting the ParagraphsBlock.
        attribute :contents,
                  Metanorma::BasicDocument::Paragraphs::ParagraphWithFootnote, collection: true

        xml do
          element "paragraphs-block"
          map_element "contents", to: :contents
        end
      end
    end
  end
end
