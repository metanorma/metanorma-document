# frozen_string_literal: true

module Metanorma
  module BsiDocument
    module Sections
      class BsiClauseSection < Metanorma::IsoDocument::Sections::IsoClauseSection
        attribute :clause, BsiClauseSection, collection: true

        attribute :floating_section_title,
                  Metanorma::StandardDocument::Sections::FloatingSectionTitle,
                  collection: true

        xml do
          element "clause"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_clause_attributes(self)
          Metanorma::StandardDocument::SectionXmlMapping.apply_clause_elements(self)

          map_element "section-title", to: :floating_section_title
        end
      end
    end
  end
end
