# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Sections
      # Term sections give elaborated definitions of terms used in a
      # standardization document.
      #
      # Corresponds to isodoc.rnc:
      #   terms = element terms {
      #     Section-Attributes, title?,
      #     ( paragraph | ul )*,
      #     term+
      #   }
      class TermsSection < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :anchor, :string
        attribute :type, :string
        attribute :number, :string
        attribute :obligation, :string
        attribute :inline_header, :string
        attribute :unnumbered, :string
        attribute :toc, :string
        attribute :class_attr, :string
        attribute :title,
                  Metanorma::Document::Components::Inline::TitleWithAnnotationElement

        # Prefatory paragraphs before term entries
        attribute :paragraphs,
                  Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true
        attribute :unordered_lists,
                  Metanorma::Document::Components::Lists::UnorderedList,
                  collection: true

        # Term entries
        attribute :terms,
                  Metanorma::StandardDocument::Terms::Term,
                  collection: true

        # Presentation-specific attributes
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

        xml do
          element "terms"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_content_section_attributes(self)

          map_element "title",            to: :title
          map_element "variant-title",    to: :variant_title
          map_element "fmt-title",        to: :fmt_title
          map_element "fmt-xref-label",   to: :fmt_xref_label
          map_element "p",                to: :paragraphs
          map_element "ul",               to: :unordered_lists
          map_element "term",             to: :terms
        end
      end
    end
  end
end
