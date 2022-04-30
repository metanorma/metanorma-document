# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Description of a bibliographic resource.
  class BibliographicItem < Core::Node
    include Core::Node::Custom

    register_element do
      # The type of the bibliographic item.
      nodes :type, Relaton::BibItemType

      # The date at which the bibliographic item was last updated.
      nodes :fetched, Relaton::DateTime

      # The title(s) of the bibliographic item.
      #
      # NOTE: `formattedRef` and `title` are mutually exclusive.
      nodes :title, Relaton::TypedTitleString

      # A pre-formatted version of the full bibliographic item reference,
      # rendered for human reading, and
      # used to sidestep the rendering of the reference out of its component parts.
      #
      # NOTE: `formattedRef` and `title` are mutually exclusive.
      nodes :formatted_ref, FormattedString

      # The URI(s) associated with the bibliographic item.
      nodes :link, Relaton::TypedUri

      # The identifier(s) of the bibliographic item in an international standard scheme.
      nodes :docidentifier, Relaton::DocumentIdentifier

      # Unprefixed, preferably numeric version of an identifier of the bibliographic item,
      # intended for sorting of biblio.
      nodes :docnumber, String

      # One or more date-times associated with the production of or access to the bibliographic item.
      nodes :date, Relaton::BibliographicDate

      # Contributors to the production of the bibliographic item.
      nodes :contributor, Relaton::ContributionInfo

      # The edition of the bibliographic item.
      nodes :edition, Relaton::Edition

      # The version of the bibliographic item (within an edition). Can be used for drafts.
      nodes :version, Relaton::VersionInfo

      # Note(s) associated with the bibliographic item.
      nodes :note, Relaton::TypedNote

      # The language(s) in which the bibliographic item is expressed.
      nodes :language, Iso639Code

      # The script(s) in which the bibliographic item is written.
      nodes :script, Iso15924Code

      # The abstract of the bibliographic item.
      nodes :abstract, FormattedString

      # The publication or preparation status of the bibliographic item.
      nodes :status, Relaton::DocumentStatus

      # The copyright status of the bibliographic item.
      nodes :copyright, Relaton::CopyrightAssociation

      # The relation(s) of the bibliographic item to other bibliographic items.
      nodes :relation, Relaton::DocumentRelation

      # The series of the bibliographic item.
      nodes :series, Relaton::SeriesType

      # The medium the subject is realized on.
      #
      # Medium can be used to differentiate between "electronic" and
      # "physical" manifestations of an information resource.
      nodes :medium, Relaton::MediumType

      # The geographic location associated with the production of the bibliographic item.
      nodes :place, Relaton::PlaceType

      # The price set on accessing the bibliographic item.
      # The price should be treated as nominal, rather than capturing all possible pricings at a given time.
      nodes :price, Relaton::PriceType

      # The extent of the bibliographic item, if reference is not being made to the entirety of the item
      # described.
      # Repeats for different levels of granularity (e.g. volume number, page number), or for discontinuous
      # ranges
      # (e.g. multiple page ranges, pages plus plates).
      nodes :extent, Relaton::LocalityStack

      # The bibliographic size of the bibliographic item, measured in the same units as extent (i.e. pages,
      # volumes,
      # megabytes, hours, rather than cm^2.) Distinct from the physical size of the bibliographic item,
      # captured in medium/size.
      nodes :size, Relaton::BibItemSize

      # The location where the bibliographic item may be accessed.
      # Used for archival resources. Also used for pathways to access digital resources, where a URI is not
      # practical.
      nodes :access_location, String

      # A license under which the bibliographic item has been issued.
      #
      # NOTE: This should preferably be encoded as  a URI or short identifier, rather than descriptive text.
      nodes :license, String

      # The classification of the bibliographic item according to a standard classification scheme.
      nodes :classification, Relaton::DocumentIdentifier

      # Keyword(s) for the bibliographic item.
      nodes :keyword, Relaton::KeywordType

      # Information about how long the current description of the bibliographic item is valid for.
      nodes :validity, Relaton::ValidityType
    end
  end
end; end; end
