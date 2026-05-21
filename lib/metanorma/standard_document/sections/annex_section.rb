# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Sections
      # An annex section in the document.
      # Corresponds to isodoc.rnc `Annex-Section-Body`:
      #   Annex-Section-Attributes, title?,
      #   ( BasicBlock*,
      #     (annex-subsection | terms | definitions | references | floating-title)* )
      #
      # Uses `ordered` to enable `each_mixed_content` for document-order iteration.
      class AnnexSection < Lutaml::Model::Serializable
        include Metanorma::StandardDocument::BlockAttributes

        # Section identity and classification
        attribute :id, :string
        attribute :number, :string
        attribute :obligation, :string
        attribute :unnumbered, :string
        attribute :toc, :string
        attribute :inline_header, :string
        attribute :title,
                  Metanorma::Document::Components::Inline::TitleWithAnnotationElement

        # Sub-clauses within annex (recursive)
        attribute :clause, AnnexSection, collection: true

        # Appendix (sub-sections unique to annex)
        attribute :appendix, ClauseSection, collection: true

        # Terms, definitions, references within annex
        attribute :terms,
                  Metanorma::StandardDocument::Sections::TermsSection,
                  collection: true
        attribute :definitions,
                  Metanorma::StandardDocument::Sections::DefinitionSection,
                  collection: true
        attribute :references,
                  Metanorma::StandardDocument::Sections::StandardReferencesSection,
                  collection: true

        # Floating titles
        attribute :floating_title,
                  Metanorma::StandardDocument::Sections::FloatingTitle,
                  collection: true

        # Page breaks
        attribute :pagebreak,
                  Metanorma::Document::Components::EmptyElements::PageBreakElement,
                  collection: true

        # Presentation-specific attributes
        attribute :anchor, :string
        attribute :semx_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer
        attribute :language, :string
        attribute :script, :string
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
          element "annex"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_annex_attributes(self)
          Metanorma::StandardDocument::SectionXmlMapping.apply_annex_elements(self)
        end

        # Blocks in document order, used by JSON serialization
        def blocks
          @blocks ||=
            begin
              result = []
              each_mixed_content do |node|
                result << node unless node.is_a?(String)
              end
              result
            end
        end
      end
    end
  end
end
