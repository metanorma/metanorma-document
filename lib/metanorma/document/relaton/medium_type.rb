# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Information about the medium and transmission of a bibliographic item.
  class MediumType < Core::Node
    include Core::Node::Custom

    register_element do
      # The content type of the bibliographic item, reflecting the form of
      # communication with which it is expressed and perceived. For example,
      # `text`, `video`, `audio`.
      #
      # NOTE: This field is intended to convey the
      # Content attribute of the MARC and Resource Description and Access
      # standards, although its values are not restricted to that
      # vocabulary; see http://www.loc.gov/standards/valuelist/rdacontent.html
      attribute :content, String

      # The genre of the bibliographic item, as a classification of the
      # type of communication it represents that is more specific than `content` or
      # `BibliographicItem/type`.
      # For example, "statistical dataset".
      attribute :genre, String

      # The media type of the bibliographic item, used to access the content
      # of the item, including file format for electronic media.
      #
      # NOTE: This field is intended to convey the
      # Media attribute of the MARC and Resource Description and Access
      # standards, although its values are not restricted to that
      # vocabulary; see http://www.loc.gov/standards/valuelist/rdamedia.html
      # IANA Media Types are recommended for electronic resources.
      attribute :form, String

      # The storage medium of the physical representation of the bibliographic item.
      #
      # NOTE: This field is intended to convey the
      # Carrier attribute of the MARC and Resource Description and Access
      # standards, although its values are not restricted to that
      # vocabulary; see https://www.loc.gov/standards/valuelist/rdacarrier.html
      attribute :carrier, String

      # The size of the physical representation of the bibliographic item.
      attribute :size, String

      # The scale of the cartographic material in the bibliographic item.
      attribute :scale, String
    end
  end
end; end; end
