# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Type of numbering applied to the list items in an ordered list.
  class OrderedListType < Core::Node::Enum
    # Lowercase Roman numbers.
    ROMAN = new("roman")

    # Ordered lowercase Roman letters.
    ALPHABET = new("alphabet")

    # Arabic numbers.
    ARABIC = new("arabic")

    # Uppercase Roman numbers.
    ROMAN_UPPER = new("romanUpper")

    # Ordered uppercase Roman letters.
    ALPHABET_UPPER = new("alphabetUpper")
  end
end; end; end
