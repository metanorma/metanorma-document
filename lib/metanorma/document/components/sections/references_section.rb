# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Sections
        # Sections containing zero or more bibliographical items (as described in Relaton),
        # along with any prefatory text.
        #
        # Admonition children (e.g. `[EDITOR]` editorial notes following the
        # reference list) are part of the section content: without the
        # mapping they were dropped at model ingest and never reached the
        # renderers (metanorma-iso#1764).
        class ReferencesSection < BasicSection
          attribute :references, Metanorma::Document::Components::BibData::BibliographicItem,
                    collection: true

          attribute :admonition, Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                    collection: true

          attribute :passthrough, Metanorma::Document::Components::Blocks::Passthrough,
                    collection: true

          xml do
            element "references-section"
            map_element "references", to: :references
            map_element "admonition", to: :admonition
            map_element "passthrough", to: :passthrough
          end
        end
      end
    end
  end
end
