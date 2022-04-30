# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Keyword for a bibliographic item.
  # Is represented in one of three ways: as a string (uncontrolled vocabulary);
  # as a string with associated identifiers (controlled vocabulary);
  # or as a hierarchical sequence of strings with associated identifiers (taxonomy).
  class KeywordType < Core::Node
  end
end; end; end
