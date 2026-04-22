# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Sections
      # Sections containing zero or more bibliographical items (as described in Relaton),
      # along with any prefatory text.
      class ReferencesSection < Metanorma::BasicDocument::Sections::BasicSection
        attribute :references,
                  Metanorma::BasicDocument::BibData::BibliographicItem, collection: true

        xml do
          element "references-section"
          map_element "references", to: :references
        end
      end
    end
  end
end
