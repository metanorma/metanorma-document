# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Paragraphs
        autoload :ParagraphBlock, "#{__dir__}/paragraphs/paragraph_block"
        autoload :ParagraphWithFootnote,
                 "#{__dir__}/paragraphs/paragraph_with_footnote"
        autoload :TextAlignment, "#{__dir__}/paragraphs/text_alignment"
      end
    end
  end
end
