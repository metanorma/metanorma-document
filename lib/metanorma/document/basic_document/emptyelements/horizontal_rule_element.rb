# frozen_string_literal: true

require "metanorma/document/basic_document/emptyelements/basic_element"

module Metanorma; module Document; module BasicDocument
  # Horizontal rule.
  class HorizontalRuleElement < BasicElement
    register_element "hr"
  end
end; end; end
