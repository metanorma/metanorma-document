# frozen_string_literal: true

require "metanorma/document/standard_document/sections/standard_content_section"

module Metanorma; module Document; module StandardDocument
  # Foreword of document.
  class Foreword < StandardContentSection
    register_element "foreword"
  end
end; end; end
