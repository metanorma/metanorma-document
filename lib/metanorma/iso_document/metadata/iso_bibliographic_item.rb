# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # The bibliographical description of an ISO/IEC document.
      # Language element with current attribute.
      class LanguageElement < Lutaml::Model::Serializable
        attribute :current, :string
        attribute :value, :string

        xml do
          element "language"
          map_attribute "current", to: :current
          map_content to: :value
        end
      end

      # Script element with current attribute.
      class ScriptElement < Lutaml::Model::Serializable
        attribute :current, :string
        attribute :value, :string

        xml do
          element "script"
          map_attribute "current", to: :current
          map_content to: :value
        end
      end

      class IsoBibliographicItem < Lutaml::Model::Serializable
        # Identifier of the document.
        attribute :doc_identifier, DocIdentifier, collection: true

        # Collection of all title elements, grouped by language via consolidation mapping.
        # Access: titles.items (raw), titles.per_language (grouped), titles.for_language("en")
        attribute :titles, AbstractTitle, collection: TitleCollection

        # Type of the document.
        attribute :type, :string

        # Fetched date
        attribute :fetched, Metanorma::Document::Relaton::DateTime

        # URIs associated with the document.
        attribute :uri, Metanorma::Document::Relaton::TypedUri, collection: true

        # Link/source
        attribute :source, :string, collection: true

        # Document number
        attribute :docnumber, :string

        # Contributors
        attribute :contributor, Metanorma::Document::Relaton::ContributionInfo,
                  collection: true

        # Edition
        attribute :edition, Metanorma::Document::Relaton::Edition,
                  collection: true

        # Version
        attribute :version, Metanorma::Document::Relaton::VersionInfo

        # Notes
        attribute :note, Metanorma::Document::Relaton::TypedNote,
                  collection: true

        # Language codes
        attribute :language, LanguageElement, collection: true

        # Script codes
        attribute :script, ScriptElement, collection: true

        # Abstract of the document.
        attribute :abstract, Metanorma::Document::Components::DataTypes::FormattedString,
                  collection: true

        # Publication status of the document.
        attribute :status, IsoDocumentStatus

        # Copyright information
        attribute :copyright, Metanorma::Document::Relaton::CopyrightAssociation,
                  collection: true

        # Relations to other documents
        attribute :relation, Metanorma::Document::Relaton::DocumentRelation,
                  collection: true

        # Formatted reference
        attribute :formattedref, Metanorma::Document::Components::DataTypes::FormattedString

        # Dates
        attribute :date, Metanorma::Document::Relaton::BibliographicDate,
                  collection: true

        # Place of publication
        attribute :place, :string, collection: true

        # Extension point of the bibliographical description.
        attribute :ext, IsoBibDataExtensionType
        attribute :keyword, Metanorma::Document::Relaton::KeywordType,
                  collection: true
        attribute :series, Metanorma::Document::Relaton::SeriesType,
                  collection: true
        attribute :editorialgroup, Metanorma::StandardDocument::Metadata::EditorialGroupType
        attribute :semx_id, :string

        # Schema version (used by collection/entry bibdata, e.g. "v1.2.9").
        attribute :schema_version, :string

        xml do
          element "bibdata"
          ordered
          map_attribute "type", to: :type
          map_attribute "schema-version", to: :schema_version
          map_element "fetched", to: :fetched
          map_element "title", to: :titles
          map_element "uri", to: :uri
          map_element "link", to: :source
          map_element "docidentifier", to: :doc_identifier
          map_element "docnumber", to: :docnumber
          map_element "contributor", to: :contributor
          map_element "edition", to: :edition
          map_element "version", to: :version
          map_element "note", to: :note
          map_element "language", to: :language
          map_element "script", to: :script
          map_element "abstract", to: :abstract
          map_element "status", to: :status
          map_element "copyright", to: :copyright
          map_element "relation", to: :relation
          map_element "formattedref", to: :formattedref
          map_element "date", to: :date
          map_element "place", to: :place
          map_element "ext", to: :ext
          map_element "keyword", to: :keyword
          map_element "series", to: :series
          map_element "editorial-group", to: :editorialgroup
          map_attribute "semx-id", to: :semx_id
        end

        json do
          map "doc_identifier", to: :doc_identifier
          map "titles", to: :titles
          map "type", to: :type
          map "status", to: :status
          map "source", to: :source
          map "abstract", to: :abstract
          map "ext", to: :ext
        end

        # Returns the title for a given language (defaults to English)
        # Uses consolidation-mapped per_language grouping for efficiency
        def title_for(language = "en")
          return nil unless titles

          if titles.is_a?(TitleCollection)
            titles.for_language(language)
          elsif titles.is_a?(Array)
            titles.find { |t|
              lang = safe_attr(t, :language) || safe_attr(t, :lang)
              lang == language
            }
          end
        end

        # Primary title (English by default)
        def title
          @title ||= title_for("en")
        end
      end
    end
  end
end
