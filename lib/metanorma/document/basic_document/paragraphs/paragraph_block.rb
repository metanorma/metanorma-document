# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Default block of textual content.
  # Unlike the case for other document models, paragraphs _cannot_
  # contain other blocks, such as lists, tables, or figures: they are modelled as a basic building block
  # of text.
  class ParagraphBlock < Core::Node
  end
end; end; end
