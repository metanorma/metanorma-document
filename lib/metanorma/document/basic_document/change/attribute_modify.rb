# frozen_string_literal: true

require "metanorma/document/basic_document/change/content_modify"

module Metanorma; module Document; module BasicDocument
  # A container for a multiple _AttributeChangeAction_ data.
  # Add attribute; Remove attribute; Modify attribute.
  class AttributeModify < ContentModify
    register_element do
      # One or more `AttributeChangeAction` data.
      nodes :actions, AttributeChangeAction
    end
  end
end; end; end
