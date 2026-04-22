# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module BibData
        # Description of a bibliographic resource.
        class BibliographicItem < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :type, Metanorma::Document::Relaton::BibItemType
          attribute :fetched, Metanorma::Document::Relaton::DateTime
          attribute :title, Metanorma::Document::Relaton::TypedTitleString,
                    collection: true
          attribute :formatted_ref, Metanorma::Document::Components::DataTypes::FormattedString
          attribute :link, Metanorma::Document::Relaton::TypedUri,
                    collection: true
          attribute :docidentifier, Metanorma::Document::Relaton::DocumentIdentifier,
                    collection: true
          attribute :docnumber, :string
          attribute :date, Metanorma::Document::Relaton::BibliographicDate,
                    collection: true
          attribute :contributor, Metanorma::Document::Relaton::ContributionInfo,
                    collection: true
          attribute :edition, Metanorma::Document::Relaton::Edition
          attribute :version, Metanorma::Document::Relaton::VersionInfo
          attribute :note, Metanorma::Document::Relaton::TypedNote,
                    collection: true
          attribute :language, Metanorma::Document::Components::DataTypes::Iso639Code,
                    collection: true
          attribute :script, Metanorma::Document::Components::DataTypes::Iso15924Code,
                    collection: true
          attribute :abstract, Metanorma::Document::Components::DataTypes::FormattedString,
                    collection: true
          attribute :status, Metanorma::Document::Relaton::DocumentStatus
          attribute :copyright, Metanorma::Document::Relaton::CopyrightAssociation,
                    collection: true
          attribute :relation, Metanorma::Document::Relaton::DocumentRelation,
                    collection: true
          attribute :series, Metanorma::Document::Relaton::SeriesType,
                    collection: true
          attribute :medium, Metanorma::Document::Relaton::MediumType
          attribute :place, Metanorma::Document::Relaton::PlaceType,
                    collection: true
          attribute :price, Metanorma::Document::Relaton::PriceType,
                    collection: true
          attribute :extent, Metanorma::Document::Relaton::LocalityStack,
                    collection: true
          attribute :size, Metanorma::Document::Relaton::BibItemSize,
                    collection: true
          attribute :access_location, :string, collection: true
          attribute :license, :string, collection: true
          attribute :classification, Metanorma::Document::Relaton::DocumentIdentifier,
                    collection: true
          attribute :keyword, Metanorma::Document::Relaton::KeywordType,
                    collection: true
          attribute :validity, Metanorma::Document::Relaton::ValidityType

          # Presentation-specific
          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :schema_version, :string
          attribute :biblio_tag, Metanorma::Document::Components::Inline::BiblioTagElement
          attribute :type_attr, :string

          xml do
            element "bibitem"
            map_attribute "id", to: :id
            map_attribute "type", to: :type_attr
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_attribute "schema-version", to: :schema_version
            map_element "biblio-tag", to: :biblio_tag
            map_element "type", to: :type
            map_element "fetched", to: :fetched
            map_element "title", to: :title
            map_element "formattedref", to: :formatted_ref
            map_element "uri", to: :link
            map_element "docidentifier", to: :docidentifier
            map_element "docnumber", to: :docnumber
            map_element "date", to: :date
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
            map_element "series", to: :series
            map_element "medium", to: :medium
            map_element "place", to: :place
            map_element "price", to: :price
            map_element "extent", to: :extent
            map_element "size", to: :size
            map_element "accessLocation", to: :access_location
            map_element "license", to: :license
            map_element "classification", to: :classification
            map_element "keyword", to: :keyword
            map_element "validity", to: :validity
          end
        end
      end
    end
  end
end
