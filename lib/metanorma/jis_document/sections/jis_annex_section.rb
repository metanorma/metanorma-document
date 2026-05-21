# frozen_string_literal: true

module Metanorma
  module JisDocument
    module Sections
      class JisAnnexSection < Metanorma::IsoDocument::Sections::IsoAnnexSection
        attribute :commentary, :string

        xml do
          element "annex"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_annex_attributes(self)
          map_attribute "commentary", to: :commentary
          Metanorma::StandardDocument::SectionXmlMapping.apply_annex_elements(self)
        end
      end
    end
  end
end
