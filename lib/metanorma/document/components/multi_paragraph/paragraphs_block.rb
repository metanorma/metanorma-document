# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module MultiParagraph
        # Block composed of multiple paragraphs.
        class ParagraphsBlock < Metanorma::Document::Components::Paragraphs::ParagraphWithFootnote
          # The paragraphs constituting the ParagraphsBlock.
          attribute :contents, Metanorma::Document::Components::Paragraphs::ParagraphWithFootnote,
                    collection: true

          xml do
            element "paragraphs-block"
            map_element "contents", to: :contents
          end
        end
      end
    end
  end
end
