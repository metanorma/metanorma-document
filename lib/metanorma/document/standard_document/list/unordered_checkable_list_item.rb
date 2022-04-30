# frozen_string_literal: true

# require "metanorma/document/basic_document/lists/list_item"

module Metanorma; module Document; module StandardDocument
  # List item for unordered lists for standards documents.
  class UnorderedCheckableListItem < Core::Node
    include Core::Node::Custom

    register_element do
      # Include a checkbox for the list item.
      attribute :checkbox, TrueClass

      # Check the checkbox for the list item.
      attribute :checkedcheckbox, TrueClass
    end
  end
end; end; end
