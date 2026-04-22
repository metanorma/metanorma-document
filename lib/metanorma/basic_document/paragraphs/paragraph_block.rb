# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Paragraphs
      # Default block of textual content.
      # Unlike the case for other document models, paragraphs _cannot_
      # contain other blocks, such as lists, tables, or figures: they are modelled as a basic building block
      # of text.
      class ParagraphBlock < Metanorma::BasicDocument::Blocks::BasicBlock
        # Inline elements constituting the content of the paragraph.
        attribute :contents,
                  Metanorma::BasicDocument::EmptyElements::BasicElement, collection: true

        # The alignment of the paragraph against the margins of the document.
        # Text alignment is the only concession the modelling of paragraphs makes to rendering, and is there
        # because the application of alignment to paragraphs, while rare, can be unpredictable from paragraph
        # semantics. Other rendering attributes of paragraphs, such as spacing before and after, are
        # considered to be semantically predictable and are relegated to document stylesheets.
        attribute :alignment, Metanorma::BasicDocument::Paragraphs::TextAlignment

        xml do
          element "p"
          map_element "contents", to: :contents
          map_element "alignment", to: :alignment
        end
      end
    end
  end
end
