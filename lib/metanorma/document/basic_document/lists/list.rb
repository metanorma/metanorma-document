# frozen_string_literal: true

require "metanorma/document/basic_document/blocks/basic_block"

module Metanorma; module Document; module BasicDocument
  # List block.
  class List < BasicBlock
    register_element do
      # Item in a list block.
      nodes :listitem, BasicObject # Actually it's ListItem
    end
  end
end; end; end
