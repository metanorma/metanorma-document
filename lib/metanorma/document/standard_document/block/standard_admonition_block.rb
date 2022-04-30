# frozen_string_literal: true

require "basic_document/multiparagraphs/admonition_block"

module Metanorma; module Document; module StandardDocument
  class StandardAdmonitionBlock < BasicDocument::AdmonitionBlock
    register_element do
      # Display the admonition on the document cover page.
      nodes :cover_page, TrueClass

      # Do not insert text labelling the type of admonition in rendering.
      nodes :notag, TrueClass
    end
  end
end; end; end
