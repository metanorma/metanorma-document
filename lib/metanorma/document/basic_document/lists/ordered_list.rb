# frozen_string_literal: true

require "metanorma/document/basic_document/lists/unordered_list"

module Metanorma; module Document; module BasicDocument
  # Ordered list, with numbering applied to the list items.
  class OrderedList < UnorderedList
    register_element "ol" do
      # Type of numbering to be applied to the list items.
      attribute :type, OrderedListType

      # Starting value for numbering of the list items.
      node :start, String
    end
  end
end; end; end
