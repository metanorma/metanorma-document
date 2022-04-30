# frozen_string_literal: true

require "metanorma/document/basic_document/sections/basic_section"

module Metanorma; module Document; module BasicDocument
  # Sections containing zero or more bibliographical items (as described in Relaton),
  # along with any prefatory text.
  class ReferencesSection < BasicSection
    register_element do
      # Bibliographical items included in the References Section.
      nodes :references, BibliographicItem
    end
  end
end; end; end
