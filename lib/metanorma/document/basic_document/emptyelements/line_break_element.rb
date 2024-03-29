# frozen_string_literal: true

require "metanorma/document/basic_document/emptyelements/basic_element"

module Metanorma; module Document; module BasicDocument
  # Line break.
  class LineBreakElement < BasicElement
    register_element "br"
  end
end; end; end
