# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Sections
      # A content section used for preface elements (abstract, foreword,
      # introduction, acknowledgements, executivesummary) and generic clauses
      # within preface.
      # Corresponds to isodoc.rnc `Content-Section`:
      #   Section-Attributes, type?, title?,
      #   ( BasicBlock*, content-subsection* )
      class ContentSection < Lutaml::Model::Serializable
        include Metanorma::StandardDocument::BlockAttributes

        # Section identity
        attribute :id, :string
        attribute :type, :string
        attribute :number, :string
        attribute :obligation, :string
        attribute :inline_header, :string
        attribute :unnumbered, :string
        attribute :toc, :string
        attribute :class_attr, :string
        attribute :title,
                  Metanorma::Document::Components::Inline::TitleWithAnnotationElement

        # Nested content subsections (recursive)
        attribute :subsection, ContentSection, collection: true

        # Presentation-specific attributes
        attribute :anchor, :string
        attribute :semx_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer
        attribute :fmt_title,
                  Metanorma::Document::Components::Inline::FmtTitleElement
        attribute :fmt_xref_label,
                  Metanorma::Document::Components::Inline::FmtXrefLabelElement,
                  collection: true
        attribute :variant_title,
                  Metanorma::Document::Components::Inline::VariantTitleElement,
                  collection: true
        attribute :fmt_annotation_start,
                  Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
                  collection: true
        attribute :fmt_annotation_end,
                  Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
                  collection: true

        xml do
          element "clause"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_content_section_attributes(self)
          Metanorma::StandardDocument::SectionXmlMapping.apply_content_section_elements(self)
        end
      end
    end
  end
end
