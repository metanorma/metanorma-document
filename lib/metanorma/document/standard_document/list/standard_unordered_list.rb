# frozen_string_literal: true

require "basic_document/lists/unordered_list"

module Metanorma; module Document; module StandardDocument
  # Ordered list for standards documents.
  class StandardUnorderedList < BasicDocument::UnorderedList
    register_element
  end
end; end; end
