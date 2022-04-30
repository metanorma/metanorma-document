# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Series to which a bibliographic item belongs. Series is to be understood broadly,
  # and it includes monograph series, journals, newspapers, and report series within
  # which the bibliographic item has appeared.
  class SeriesType < Core::Node
    include Core::Node::Custom

    register_element do
      # The type of series description expressed in this container.
      attribute :type, SeriesTypeType

      # Fully formatted human-readable reference for the subject series.
      #
      # NOTE: `formattedref` is mutually exclusive with other attributes in SeriesType.
      node :formattedref, BasicDocument::FormattedString

      # The title of the series.
      #
      # NOTE: `formattedref` and `title` are mutually exclusive.
      node :title, TypedTitleString

      # The place where the series is issued; used for disambiguation.
      attribute :place, String

      # The organization issuing the series; used for disambiguation.
      attribute :organization, String

      # The abbreviation under which the series is known.
      node :abbrev, BasicDocument::LocalizedString

      # The start of the date range when the series has been known under the given title.
      node :from, DateTime

      # The end of the date range when the series has been known under the given title.
      node :to, DateTime

      # The number of the bibliographic item within the series.
      attribute :number, String

      # The part-number of the bibliographic item within the series. For example,
      # if the series is a journal, the number is the volume number, and the partnumber
      # is the issue number.
      attribute :partnumber, String

      # An iteration of numbering of the series, if the series has restarted numbering
      # (as occurs in some journals); referred to as "series" in the context of journals.
      # For example, "n.s." (new series) or "2" indicates
      # that the `number` given for the series applies to the second iteration of numbering.
      attribute :run, String

      # A pre-formatted version of the series description, incorporating
      # all needed disambiguating information in human-readable format.
      #
      # NOTE: `formattedref` and `title` are mutually exclusive.
      attribute :formattedref, String
    end
  end
end; end; end
