# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Terms section specific to ISO/IEC documents.
      # Maps <terms> element with <title>, <p>, <ul>, <term> children.
      class IsoTermsSection < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :anchor, :string
        attribute :type, :string
        attribute :number, :string
        attribute :obligation, :string
        attribute :inline_header, :string
        attribute :title, Metanorma::Document::Components::Inline::TitleWithAnnotationElement
        attribute :p, RawParagraph, collection: true
        attribute :ul, Metanorma::Document::Components::Lists::UnorderedList,
                  collection: true
        attribute :term, Metanorma::IsoDocument::Terms::IsoTerm,
                  collection: true

        # Examples directly inside terms section
        attribute :example,
                  Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                  collection: true

        # Admonitions directly inside terms section
        attribute :admonition,
                  Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                  collection: true

        # Definition lists directly inside terms section
        attribute :dl,
                  Metanorma::Document::Components::Lists::DefinitionList,
                  collection: true

        # Definitions section within terms
        attribute :definitions,
                  Metanorma::StandardDocument::Sections::DefinitionSection

        # Nested terms sections (terms within terms)
        attribute :terms, IsoTermsSection, collection: true

        # Nested clause sections inside terms
        attribute :clause, IsoClauseSection, collection: true
        attribute :semx_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer
        attribute :fmt_title, Metanorma::Document::Components::Inline::FmtTitleElement
        attribute :fmt_xref_label,
                  Metanorma::Document::Components::Inline::FmtXrefLabelElement, collection: true
        attribute :fmt_annotation_start,
                  Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
                  collection: true
        attribute :fmt_annotation_end,
                  Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
                  collection: true

        xml do
          element "terms"
          map_attribute "id", to: :id
          map_attribute "anchor", to: :anchor
          map_attribute "type", to: :type
          map_attribute "number", to: :number
          map_attribute "obligation", to: :obligation
          map_attribute "inline-header", to: :inline_header
          map_element "title", to: :title
          map_element "fmt-title", to: :fmt_title
          map_element "fmt-xref-label", to: :fmt_xref_label
          map_element "p", to: :p
          map_element "ul", to: :ul
          map_element "term", to: :term
          map_element "example", to: :example
          map_element "admonition", to: :admonition
          map_element "dl", to: :dl
          map_element "definitions", to: :definitions
          map_element "terms", to: :terms
          map_element "clause", to: :clause
          map_element "fmt-annotation-start", to: :fmt_annotation_start
          map_element "fmt-annotation-end", to: :fmt_annotation_end
          map_attribute "semx-id", to: :semx_id
          map_attribute "autonum", to: :autonum
          map_attribute "displayorder", to: :displayorder
        end
      end
    end
  end
end
