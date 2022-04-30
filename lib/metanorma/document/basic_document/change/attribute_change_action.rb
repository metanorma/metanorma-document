# frozen_string_literal: true

require "basic_document/change/content_change_action"

module Metanorma; module Document; module BasicDocument
  # Possible actions
  # that involve modification of an attribute within a BasicDocument
  # data element.
  class AttributeChangeAction < ContentChangeAction
    register_element do
      # A `String` that identifies the attribute where the attribute change
      # should apply to.
      attribute :attribute_id, String
    end
  end
end; end; end
