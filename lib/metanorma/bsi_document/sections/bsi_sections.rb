# frozen_string_literal: true

module Metanorma
  module BsiDocument
    module Sections
      class BsiSections < Metanorma::IsoDocument::Sections::IsoSections
        attribute :floating_section_title,
                  Metanorma::StandardDocument::Sections::FloatingSectionTitle,
                  collection: true

        xml do
          element "sections"
          ordered

          map_element "note",           to: :note
          map_element "admonition",     to: :admonition

          Metanorma::StandardDocument::SectionXmlMapping.apply_sections_elements(self)
          map_element "p",              to: :p
          map_element "section-title",  to: :floating_section_title

          Metanorma::StandardDocument::SectionXmlMapping.apply_sections_attributes(self)
        end
      end
    end
  end
end
