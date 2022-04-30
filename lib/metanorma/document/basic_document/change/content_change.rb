# frozen_string_literal: true

require "basic_document/change/change"

module Metanorma; module Document; module BasicDocument
  # Possible actions
  # that involve modification of content within a BasicDocument
  # data element.
  # Add text; Delete text; Modify text.
  class ContentChange < Change
    register_element
  end
end; end; end
