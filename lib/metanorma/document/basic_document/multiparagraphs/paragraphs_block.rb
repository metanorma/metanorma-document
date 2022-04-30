# frozen_string_literal: true

require "basic_document/paragraphs/paragraph_with_footnote"

module Metanorma; module Document; module BasicDocument
  # Block composed of multiple paragraphs.
  class ParagraphsBlock < ParagraphWithFootnote
    register_element do
      # The paragraphs constituting the ParagraphsBlock.
      nodes :contents, ParagraphWithFootnote
    end
  end
end; end; end
