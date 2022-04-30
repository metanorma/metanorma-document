# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Keyword for a bibliographic item.
  # Is represented in one of three ways: as a string (uncontrolled vocabulary);
  # as a string with associated identifiers (controlled vocabulary);
  # or as a hierarchical sequence of strings with associated identifiers (taxonomy).
  class KeywordType < Core::Node
    include Core::Node::Custom

    register_element do
      # The keyword as an uncontrolled vocabulary term.
      nodes :content, String

      # The keyword as an controlled vocabulary term.
      nodes :vocab, BasicDocument::LocalizedString

      # The keyword as a taxonomy. For example, the sequence of `taxon` elements
      # `pump`, `centrifugal pump`, `line shaft pump` represents a taxonomic
      # classification.
      nodes :taxon, String

      # Identifiers for the keyword as a controlled vocabulary (including entries in taxonomies).
      nodes :vocabid, VocabIdType
    end
  end
end; end; end
