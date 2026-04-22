# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module BibData
        # The bibliographic description of a BasicDocument.
        # BibData differs from BibliographicItem by making `title` and `copyright` mandatory.
        class BibData < Lutaml::Model::Serializable
          attribute :ext, Metanorma::Document::Components::BibData::BibDataExtensionType
          attribute :title, Metanorma::Document::Relaton::TypedTitleString,
                    collection: true
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
          attribute :keyword, Metanorma::Document::Relaton::KeywordType,
                    collection: true
          attribute :classification, Metanorma::Document::Relaton::DocumentIdentifier,
                    collection: true

          xml do
            element "bibdata"
            map_element "ext", to: :ext
            map_element "title", to: :title
            map_element "uri", to: :link
            map_element "docidentifier", to: :docidentifier
            map_element "docnumber", to: :docnumber
            map_element "date", to: :date
            map_element "contributor", to: :contributor
            map_element "edition", to: :edition
            map_element "version", to: :version
            map_element "language", to: :language
            map_element "script", to: :script
            map_element "abstract", to: :abstract
            map_element "status", to: :status
            map_element "copyright", to: :copyright
            map_element "relation", to: :relation
            map_element "series", to: :series
            map_element "keyword", to: :keyword
            map_element "classification", to: :classification
          end
        end
      end
    end
  end
end
