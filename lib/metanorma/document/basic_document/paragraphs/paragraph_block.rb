# frozen_string_literal: true

require "basic_document/blocks/basic_block"

module Metanorma; module Document; module BasicDocument
  # Default block of textual content.
  # Unlike the case for other document models, paragraphs _cannot_
  # contain other blocks, such as lists, tables, or figures: they are modelled as a basic building block
  # of text.
  class ParagraphBlock < BasicBlock
    register_element "p" do
      # Inline elements constituting the content of the paragraph.
      nodes :contents, BasicElement

      # The alignment of the paragraph against the margins of the document.
      # Text alignment is the only concession the modelling of paragraphs makes to rendering, and is there
      # because the application of alignment to paragraphs, while rare, can be unpredictable from paragraph
      # semantics. Other rendering attributes of paragraphs, such as spacing before and after, are
      # considered to be semantically predictable and are relegated to document stylesheets.
      attribute :alignment, TextAlignment
    end
  end
end; end; end
