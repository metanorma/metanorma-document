# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        # Inline reference to a paragraph or paragraphs: element combining the reference and the referenced
        # content in the one element.
        class ReferenceToIdWithParagraphElement < ReferenceToIdElement
          attribute :content, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true

          xml do
            element "reference-to-id-with-paragraph-element"
            map_element "content", to: :content
          end
        end
      end
    end
  end
end
