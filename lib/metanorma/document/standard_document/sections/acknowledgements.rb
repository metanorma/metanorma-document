# frozen_string_literal: true

require "metanorma/document/standard_document/sections/standard_content_section"

module Metanorma; module Document; module StandardDocument
  # Acknowledgements for the document.
  class Acknowledgements < StandardContentSection
    register_element "acknowledgements"
  end
end; end; end
