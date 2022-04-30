# frozen_string_literal: true

require "basic_document/blocks/basic_block"

module Metanorma; module Document; module BasicDocument
  # List block.
  class List < BasicBlock
    register_element do
      # Item in a list block.
      nodes :listitem, ListItem
    end
  end
end; end; end
