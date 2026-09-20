# frozen_string_literal: true

module Metanorma
  module NistDocument
    module Sections
      class ErrataClause < Metanorma::StandardDocument::Sections::ContentSection
        attribute :errata, Errata

        xml do
          element "errata_clause"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_content_section_attributes(self)
          Metanorma::StandardDocument::SectionXmlMapping.apply_content_section_elements(self)
          map_element "errata", to: :errata
        end
      end
    end
  end
end
