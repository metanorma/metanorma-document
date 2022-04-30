# frozen_string_literal: true

require "basic_document/multiparagraphs/paragraphs_block"

module Metanorma; module Document; module BasicDocument
  # Block intended to capture reviewer comments about some text in the document.
  class ReviewBlock < ParagraphsBlock
    register_element do
      # The party who has offered the comment.
      attribute :reviewer, String

      # The date when the comment was made.
      node :date, Relaton::DateTime

      # Identifier for the start of the text or point in the text to which the comment applies.
      # If not provided, the comment applies in the vicinity of the place it has been inserted into the
      # text.
      node :applies_from, IdElement

      # Identifier for the end of the text to which the comment applies.
      node :applies_to, IdElement
    end
  end
end; end; end
