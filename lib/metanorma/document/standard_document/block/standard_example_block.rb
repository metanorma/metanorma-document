# frozen_string_literal: true

require "basic_document/ancillaryblocks/example_block"

module Metanorma; module Document; module StandardDocument
  class StandardExampleBlock < BasicDocument::ExampleBlock
    register_element do
      # Override the numbering of this block in numbering.
      nodes :number, String
    end
  end
end; end; end
