# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Type of abbreviation, according to how it is formed.
  class AbbreviationType < Core::Node::Enum
    # Abbrevation formed by truncating constituent words.
    TRUNCATION = new("truncation")

    # Abbrevation formed from the initials of its constituent words, and pronounced as a new word.
    ACRONYM = new("acronym")

    # Abbrevation formed from the initials of its constituent words, and pronounced as a sequence of
    # letters.
    INITIALISM = new("initialism")
  end
end; end; end
