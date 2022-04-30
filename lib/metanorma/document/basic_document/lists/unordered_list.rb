# frozen_string_literal: true

require "metanorma/document/basic_document/lists/list"

module Metanorma; module Document; module BasicDocument
  # Unordered list block.
  class UnorderedList < List
    register_element "ul"
  end
end; end; end
