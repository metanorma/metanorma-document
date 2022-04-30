# frozen_string_literal: true

require "metanorma/document/basic_document/change/content_change"

module Metanorma; module Document; module BasicDocument
  # Container for a multiple _ContentChangeAction_ data
  class ContentModify < ContentChange
    register_element do
      # One or more `ContentChangeAction` data.
      nodes :actions, ContentChangeAction
    end
  end
end; end; end
