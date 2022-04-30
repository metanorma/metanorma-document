# frozen_string_literal: true

require "basic_document/change/content_modify"

module Metanorma; module Document; module BasicDocument
  # A container for a multiple _AttributeChangeAction_ data.
  # Add attribute; Remove attribute; Modify attribute.
  class AttributeModify < ContentModify
  end
end; end; end
