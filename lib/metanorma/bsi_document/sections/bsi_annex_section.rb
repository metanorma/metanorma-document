# frozen_string_literal: true

module Metanorma
  module BsiDocument
    module Sections
      class BsiAnnexSection < Metanorma::IsoDocument::Sections::IsoAnnexSection
        attribute :clause, BsiClauseSection, collection: true

        attribute :floating_section_title,
                  Metanorma::StandardDocument::Sections::FloatingSectionTitle,
                  collection: true

        xml do
          element "annex"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_annex_attributes(self)
          Metanorma::StandardDocument::SectionXmlMapping.apply_annex_elements(self)

          map_element "section-title", to: :floating_section_title
        end
      end
    end
  end
end
