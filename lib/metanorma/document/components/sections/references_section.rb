# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Sections
        # Sections containing zero or more bibliographical items (as described in Relaton),
        # along with any prefatory text.
        class ReferencesSection < BasicSection
          attribute :references, Metanorma::Document::Components::BibData::BibliographicItem,
                    collection: true

          attribute :passthrough, Metanorma::StandardDocument::Blocks::Passthrough,
                    collection: true

          xml do
            element "references-section"
            map_element "references", to: :references
            map_element "passthrough", to: :passthrough
          end
        end
      end
    end
  end
end
