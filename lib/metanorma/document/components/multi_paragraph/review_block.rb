# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module MultiParagraph
        # Block intended to capture reviewer comments about some text in the document.
        class ReviewBlock < ParagraphsBlock
          # The party who has offered the comment.
          attribute :reviewer, :string

          # The date when the comment was made.
          attribute :date, :string

          # Identifier for the start of the text or point in the text to which the comment applies.
          # If not provided, the comment applies in the vicinity of the place it has been inserted into the
          # text.
          attribute :applies_from, :string

          # Identifier for the end of the text to which the comment applies.
          attribute :applies_to, :string

          xml do
            element "review"
            map_attribute "reviewer", to: :reviewer
            map_attribute "date", to: :date
            map_attribute "from", to: :applies_from
            map_attribute "to", to: :applies_to
          end
        end
      end
    end
  end
end
