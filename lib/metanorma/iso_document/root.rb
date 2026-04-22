# frozen_string_literal: true

module Metanorma
  module IsoDocument
    class Root < Metanorma::StandardDocument::Root
      # Version number of the schema used for this standards document.
      attribute :version, :string

      # Type of the document (semantic, presentation).
      attribute :type, :string

      # Schema version.
      attribute :schema_version, :string

      # Document flavor (iso, standoc, etc).
      attribute :flavor, :string

      # Bibliographic description of the document itself, expressed in the Relaton
      # model.
      attribute :bibdata, Metanorma::IsoDocument::Metadata::IsoBibliographicItem

      # Citations for sources of term definitions.
      attribute :term_sources,
                Metanorma::Document::Components::ReferenceElements::Citation,
                collection: true

      # Zero or more optional _preface_ sections.
      attribute :preface, Metanorma::IsoDocument::Sections::IsoPreface

      # One or more _sections_.
      attribute :sections, Metanorma::IsoDocument::Sections::IsoSections

      # Zero or more _annexes_.
      attribute :annex, Metanorma::IsoDocument::Sections::IsoAnnexSection,
                collection: true

      # Zero to two _bibliographies_.
      attribute :bibliography,
                Metanorma::StandardDocument::Sections::BibliographySection

      # Boilerplate section (copyright statements, license text).
      attribute :boilerplate, Boilerplate

      # Metanorma-specific extensions (semantic-metadata, presentation-metadata, UnitsML).
      attribute :metanorma_extension, Metadata::MetanormaExtension

      # Container for review annotations.
      attribute :annotation_container, AnnotationContainer

      # Index of a standards document.
      attribute :indexsect,
                Metanorma::Document::Components::Sections::BasicSection

      # Presentation-specific attributes
      attribute :autonum, :string
      attribute :fmt_xref_label, :string

      # Localized strings container (presentation XML)
      attribute :localized_strings, Metanorma::Document::Components::Inline::LocalizedStringsElement

      # Formatted footnote container (presentation XML)
      attribute :fmt_footnote_container, Metanorma::Document::Components::Inline::FmtFootnoteContainerElement

      # Colophon section (presentation XML)
      attribute :colophon, Sections::Colophon

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
