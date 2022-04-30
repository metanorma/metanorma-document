# frozen_string_literal: true

require "standard_document/sections/standard_content_section"

module Metanorma; module Document; module StandardDocument
  # Abstract of the document.
  class Abstract < StandardContentSection
    register_element "abstract"
  end
end; end; end
