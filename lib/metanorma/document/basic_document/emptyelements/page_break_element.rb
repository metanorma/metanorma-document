# frozen_string_literal: true

require "basic_document/emptyelements/basic_element"

module Metanorma; module Document; module BasicDocument
  # Page break. Only applicable in paged layouts (e.g. PDF, Word), and not
  # flow layouts (e.g. HTML).
  class PageBreakElement < BasicElement
    register_element "pagebreak"
  end
end; end; end
