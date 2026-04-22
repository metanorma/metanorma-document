# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Sections
        # Prefatory sections of text, outside the main flow of text.
        # In the BasicDocument model these are treated as equivalent to Hierarchical Sections.
        # (The distinction is currently reserved for downstream models such as Metanorma, which differentiates
        # structurally between prefatory sections and sections in the main body of the text; differences
        # between the two may be introduced in the Basic Document model at a later date.)
        class ContentSection < HierarchicalSection
          xml do
            element "content-section"
          end
        end
      end
    end
  end
end
