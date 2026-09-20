# frozen_string_literal: true

module Metanorma
  module UnDocument
    module Sections
      # UN sections container.
      # Corresponds to un.rnc:
      #   sections = element sections { (clause | floating-title)+ }
      #
      # UN does not allow terms/definitions at top level of sections.
      class UnSections < Metanorma::StandardDocument::Sections::Sections
        xml do
          element "sections"
          ordered

          map_element "clause",         to: :clause
          map_element "floating-title", to: :floating_title

          Metanorma::StandardDocument::SectionXmlMapping.apply_sections_attributes(self)
        end
      end
    end
  end
end
