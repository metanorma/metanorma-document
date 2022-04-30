# frozen_string_literal: true

require "standard_document/sections/standard_content_section"

module Metanorma; module Document; module StandardDocument
  # Introduction of document.
  class Introduction < StandardContentSection
    register_element "introduction"
  end
end; end; end
