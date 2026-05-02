# frozen_string_literal: true

require "metanorma/iso_document"

module Metanorma
  module IetfDocument
    module Sections
      class IetfSections < Metanorma::IsoDocument::Sections::IsoSections
        # Loose bibliographic items appearing directly inside sections.
        attribute :bibitem,
                  Metanorma::BasicDocument::BibData::BibliographicItem,
                  collection: true

        xml do
          element "sections"
          ordered
          map_element "note", to: :note
          map_element "admonition", to: :admonition
          map_element "terms", to: :terms
          map_element "definitions", to: :definitions
          map_element "clause", to: :clause
          map_element "references", to: :references
          map_element "bibitem", to: :bibitem
          map_element "p", to: :p
          map_attribute "semx-id", to: :semx_id
          map_attribute "displayorder", to: :displayorder
        end
      end
    end
  end
end
