# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Sections
      # Sections: groups of blocks within text, which can also contain other sections.
      class HierarchicalSection < Metanorma::BasicDocument::Sections::BasicSection
        attribute :subsections,
                  Metanorma::BasicDocument::Sections::HierarchicalSection, collection: true

        xml do
          element "hierarchical-section"
          map_element "subsections", to: :subsections
        end
      end
    end
  end
end
