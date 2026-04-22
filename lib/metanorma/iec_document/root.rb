# frozen_string_literal: true

require "metanorma/standard_document"
require "metanorma/iso_document"

module Metanorma
  module IecDocument
    class Root < Metanorma::StandardDocument::Root
      attribute :version, :string
      attribute :type, :string
      attribute :schema_version, :string
      attribute :flavor, :string

      attribute :bibdata,
                Metanorma::IsoDocument::Metadata::IsoBibliographicItem

      attribute :term_sources,
                Metanorma::Document::Components::ReferenceElements::Citation,
                collection: true

      attribute :preface, Metanorma::IsoDocument::Sections::IsoPreface
      attribute :sections, Metanorma::IsoDocument::Sections::IsoSections
      attribute :annex, Metanorma::IsoDocument::Sections::IsoAnnexSection,
                collection: true
      attribute :bibliography,
                Metanorma::StandardDocument::Sections::BibliographySection
      attribute :boilerplate, Metanorma::IsoDocument::Boilerplate
      attribute :metanorma_extension,
                Metanorma::IsoDocument::Metadata::MetanormaExtension
      attribute :annotation_container, Metanorma::IsoDocument::AnnotationContainer
      attribute :indexsect,
                Metanorma::Document::Components::Sections::BasicSection
      attribute :autonum, :string
      attribute :fmt_xref_label, :string
      attribute :localized_strings,
                Metanorma::Document::Components::Inline::LocalizedStringsElement
      attribute :fmt_footnote_container,
                Metanorma::Document::Components::Inline::FmtFootnoteContainerElement
      attribute :colophon, Metanorma::IsoDocument::Sections::Colophon

      xml do
        element "metanorma"
        namespace Metanorma::StandardDocument::Namespace
        map_attribute "type", to: :type
        map_attribute "version", to: :version
        map_attribute "schema-version", to: :schema_version
        map_attribute "flavor", to: :flavor
        map_element "bibdata", to: :bibdata
        map_element "termdocsource", to: :term_sources
        map_element "metanorma-extension", to: :metanorma_extension
        map_element "boilerplate", to: :boilerplate
        map_element "preface", to: :preface
        map_element "sections", to: :sections
        map_element "annex", to: :annex
        map_element "bibliography", to: :bibliography
        map_element "annotation-container", to: :annotation_container
        map_element "indexsect", to: :indexsect
        map_element "localized-strings", to: :localized_strings
        map_element "fmt-footnote-container", to: :fmt_footnote_container
        map_element "colophon", to: :colophon
        map_attribute "autonum", to: :autonum
        map_attribute "fmt-xref-label", to: :fmt_xref_label
      end
    end
  end
end
