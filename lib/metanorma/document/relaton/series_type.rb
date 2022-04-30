# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Series to which a bibliographic item belongs. Series is to be understood broadly,
  # and it includes monograph series, journals, newspapers, and report series within
  # which the bibliographic item has appeared.
  class SeriesType < Core::Node
    include Core::Node::Custom

    register_element do
      # The type of series description expressed in this container.
      nodes :type, SeriesTypeType

      # Fully formatted human-readable reference for the subject series.
      #
      # NOTE: `formattedref` is mutually exclusive with other attributes in SeriesType.
      nodes :formattedref, BasicDocument::FormattedString

      # The title of the series.
      #
      # NOTE: `formattedref` and `title` are mutually exclusive.
      nodes :title, TypedTitleString

      # The place where the series is issued; used for disambiguation.
      nodes :place, String

      # The organization issuing the series; used for disambiguation.
      nodes :organization, String

      # The abbreviation under which the series is known.
      nodes :abbrev, BasicDocument::LocalizedString

      # The start of the date range when the series has been known under the given title.
      nodes :from, DateTime

      # The end of the date range when the series has been known under the given title.
      nodes :to, DateTime

      # The number of the bibliographic item within the series.
      nodes :number, String

      # The part-number of the bibliographic item within the series. For example,
      # if the series is a journal, the number is the volume number, and the partnumber
      # is the issue number.
      nodes :partnumber, String

      # An iteration of numbering of the series, if the series has restarted numbering
      # (as occurs in some journals); referred to as "series" in the context of journals.
      # For example, "n.s." (new series) or "2" indicates
      # that the `number` given for the series applies to the second iteration of numbering.
      nodes :run, String

      # A pre-formatted version of the series description, incorporating
      # all needed disambiguating information in human-readable format.
      #
      # NOTE: `formattedref` and `title` are mutually exclusive.
      nodes :formattedref, String
    end
  end
end; end; end
