# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Paragraphs
      autoload :ParagraphBlock, "#{__dir__}/paragraphs/paragraph_block"
      autoload :ParagraphWithFootnote,
               "#{__dir__}/paragraphs/paragraph_with_footnote"
      autoload :TextAlignment, "#{__dir__}/paragraphs/text_alignment"
    end
  end
end
