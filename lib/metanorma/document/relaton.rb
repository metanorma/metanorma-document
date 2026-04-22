# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      autoload :Address, "#{__dir__}/relaton/address"
      autoload :Affiliation, "#{__dir__}/relaton/affiliation"
      autoload :BibItemLocality, "#{__dir__}/relaton/bib_item_locality"
      autoload :BibItemSize, "#{__dir__}/relaton/bib_item_size"
      autoload :BibItemSizeType, "#{__dir__}/relaton/bib_item_size_type"
      autoload :BibItemType, "#{__dir__}/relaton/bib_item_type"
      autoload :BibliographicDate, "#{__dir__}/relaton/bibliographic_date"
      autoload :BibliographicDateType,
               "#{__dir__}/relaton/bibliographic_date_type"
      autoload :ContactMethod, "#{__dir__}/relaton/contact_method"
      autoload :ContributionInfo, "#{__dir__}/relaton/contribution_info"
      autoload :Contributor, "#{__dir__}/relaton/contributor"
      autoload :ContributorRole, "#{__dir__}/relaton/contributor_role"
      autoload :CopyrightAssociation, "#{__dir__}/relaton/copyright_association"
      autoload :CopyrightOwner, "#{__dir__}/relaton/copyright_association"
      autoload :DateTime, "#{__dir__}/relaton/date_time"
      autoload :DocumentIdentifier, "#{__dir__}/relaton/document_identifier"
      autoload :DocumentRelation, "#{__dir__}/relaton/document_relation"
      autoload :DocumentRelationType,
               "#{__dir__}/relaton/document_relation_type"
      autoload :DocumentStatus, "#{__dir__}/relaton/document_status"
      autoload :Edition, "#{__dir__}/relaton/edition"
      autoload :FullName, "#{__dir__}/relaton/full_name"
      autoload :Iso4217Code, "#{__dir__}/relaton/iso4217_code"
      autoload :Iso8601Date, "#{__dir__}/relaton/iso8601_date"
      autoload :KeywordType, "#{__dir__}/relaton/keyword_type"
      autoload :LocalizedName, "#{__dir__}/relaton/localized_name"
      autoload :LocalityStack, "#{__dir__}/relaton/locality_stack"
      autoload :MediumType, "#{__dir__}/relaton/medium_type"
      autoload :OrgIdentifier, "#{__dir__}/relaton/org_identifier"
      autoload :OrgSubdivision, "#{__dir__}/relaton/org_subdivision"
      autoload :OrgSubdivisionIdentifier,
               "#{__dir__}/relaton/org_subdivision_identifier"
      autoload :Organization, "#{__dir__}/relaton/organization"
      autoload :Person, "#{__dir__}/relaton/person"
      autoload :PersonIdentifier, "#{__dir__}/relaton/person_identifier"
      autoload :PersonalIdentifierType,
               "#{__dir__}/relaton/personal_identifier_type"
      autoload :Phone, "#{__dir__}/relaton/phone"
      autoload :PlaceType, "#{__dir__}/relaton/place_type"
      autoload :PriceType, "#{__dir__}/relaton/price_type"
      autoload :RegionType, "#{__dir__}/relaton/region_type"
      autoload :RelatonCollection, "#{__dir__}/relaton/relaton_collection"
      autoload :SeriesType, "#{__dir__}/relaton/series_type"
      autoload :SeriesTypeType, "#{__dir__}/relaton/series_type_type"
      autoload :SpecificLocalityType,
               "#{__dir__}/relaton/specific_locality_type"
      autoload :TitleType, "#{__dir__}/relaton/title_type"
      autoload :TypedNote, "#{__dir__}/relaton/typed_note"
      autoload :TypedTitleString, "#{__dir__}/relaton/typed_title_string"
      autoload :TypedUri, "#{__dir__}/relaton/typed_uri"
      autoload :ValidityType, "#{__dir__}/relaton/validity_type"
      autoload :VariantFullName, "#{__dir__}/relaton/variant_full_name"
      autoload :VariantOrgName, "#{__dir__}/relaton/variant_org_name"
      autoload :VersionInfo, "#{__dir__}/relaton/version_info"
      autoload :VocabIdType, "#{__dir__}/relaton/vocab_id_type"
    end
  end
end
