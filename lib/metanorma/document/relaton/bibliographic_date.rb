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
      attribute :text, String

      # The start of the date range described.
      node :from, DateTime

      # The end of the date range described.
      node :to, DateTime

      # The point date described (mutually exclusive with date range).
      node :on, DateTime
    end
  end
end; end; end
