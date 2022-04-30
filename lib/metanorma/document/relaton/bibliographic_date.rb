# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Significant date in the lifecycle of the bibliographic item,
  # including its production and its access.
  class BibliographicDate < Core::Node
    include Core::Node::Custom

    register_element do
      # The phase of the production of or access to a bibliographic item.
      attribute :type, BibliographicDateType

      # An optional textual description of the date, especially when a Gregorian date is not applicable.
      nodes :text, String

      # The start of the date range described.
      nodes :from, DateTime

      # The end of the date range described.
      nodes :to, DateTime

      # The point date described (mutually exclusive with date range).
      nodes :on, DateTime
    end
  end
end; end; end
