# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module MultiParagraph
        autoload :AdmonitionBlock, "#{__dir__}/multi_paragraph/admonition_block"
        autoload :AdmonitionType, "#{__dir__}/multi_paragraph/admonition_type"
        autoload :ParagraphsBlock, "#{__dir__}/multi_paragraph/paragraphs_block"
        autoload :QuoteBlock, "#{__dir__}/multi_paragraph/quote_block"
        autoload :ReviewBlock, "#{__dir__}/multi_paragraph/review_block"
      end
    end
  end
end
