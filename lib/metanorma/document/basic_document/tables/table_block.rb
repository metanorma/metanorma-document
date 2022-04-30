# frozen_string_literal: true

require "basic_document/blocks/basic_block"

module Metanorma; module Document; module BasicDocument
  # Tabular arrangement of text
  class TableBlock < BasicBlock
    register_element do
      # Caption for the table.
      nodes :name, TextElement

      # The table should be excluded from any automatic numbering of tables in the document.
      nodes :unnumbered, TrueClass

      # Define a subsequence for numbering of this table; e.g. if this table would be numbered
      # as 7, but it has a subsequence value of XYZ, this table, and all consecutive table
      # with the same subsequence value, will be numbered consecutively
      # with the same number and in a subsequence: 7a, 7b, 7c etc.
      nodes :subsequence, String

      # Accessible description of the tabular text, in case the table cannot be rendered accessibly.
      nodes :alt, String

      # Alternative more extensive summary of table to be provided for accessibility purposes, in case the
      # table cannot be rendered accessibly.
      nodes :summary, String

      # Online location of content of table (in case the table is available as a separate external
      # document).
      nodes :uri, Uri

      # Table rows constituting the table header.
      nodes :head, TextTableRow

      # Table rows constituting the table body.
      nodes :body, TextTableRow

      # Table rows constituting the table footer.
      nodes :foot, TextTableRow

      # Definitions list defining any symbols used in the table.
      nodes :definitions, DefinitionList
    end
  end
end; end; end
