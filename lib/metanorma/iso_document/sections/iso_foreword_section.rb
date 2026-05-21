# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Foreword section of an ISO/IEC document.
      # Extends ContentSection (blocks + optional subsections) but maps to
      # the "foreword" element. ISO foreword typically has no subsections.
      class IsoForewordSection < Metanorma::StandardDocument::Sections::ContentSection
        xml do
          element "foreword"
          ordered

          map_attribute "id",             to: :id
          map_attribute "anchor",         to: :anchor
          map_attribute "obligation",     to: :obligation
          map_attribute "semx-id",        to: :semx_id
          map_attribute "displayorder",   to: :displayorder

          map_element "title",            to: :title
          map_element "fmt-title",        to: :fmt_title

          Metanorma::StandardDocument::BlockXmlMapping.apply_block_mappings(self)

          map_element "fmt-annotation-start", to: :fmt_annotation_start
          map_element "fmt-annotation-end",   to: :fmt_annotation_end
        end

        json do
          map "id", to: :id
          map "title", to: :title
          map "paragraphs", to: :paragraphs
          map "unordered_lists", to: :unordered_lists
          map "ordered_lists", to: :ordered_lists
          map "tables", to: :tables
          map "figures", to: :figures
          map "formulas", to: :formulas
          map "examples", to: :examples
          map "notes", to: :notes
        end
      end
    end
  end
end
