# frozen_string_literal: true

module Metanorma
  module IeeeDocument
    module Sections
      # IEEE sections container.
      # Corresponds to ieee.rnc:
      #   sections = element sections {
      #     note?,
      #     ( clause | terms | term-clause | definitions | floating-title )+
      #   }
      #
      # Differs from isodoc default by adding an optional leading note.
      class IeeeSections < Metanorma::StandardDocument::Sections::Sections
        attribute :note,
                  Metanorma::Document::Components::Blocks::NoteBlock

        xml do
          element "sections"
          ordered

          map_element "note", to: :note

          Metanorma::StandardDocument::SectionXmlMapping.apply_sections_elements(self)

          Metanorma::StandardDocument::SectionXmlMapping.apply_sections_attributes(self)
        end
      end
    end
  end
end
