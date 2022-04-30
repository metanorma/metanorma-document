# frozen_string_literal: true

require "metanorma/document/basic_document/sections/hierarchical_section"

module Metanorma; module Document; module BasicDocument
  # Prefatory sections of text, outside the main flow of text.
  # In the BasicDocument model these are treated as equivalent to Hierarchical Sections.
  # (The distinction is currently reserved for downstream models such as Metanorma, which differentiates
  # structurally between prefatory sections and sections in the main body of the text; differences
  # between the two may be introduced in the Basic Document model at a later date.)
  class ContentSection < HierarchicalSection
    register_element
  end
end; end; end
