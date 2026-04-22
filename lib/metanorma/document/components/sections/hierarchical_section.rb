# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Sections
        # Sections: groups of blocks within text, which can also contain other sections.
        class HierarchicalSection < BasicSection
          attribute :subsections, HierarchicalSection, collection: true

          xml do
            element "hierarchical-section"
            map_element "subsections", to: :subsections
          end
        end
      end
    end
  end
end
