# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The relation of a term to the current term.
  class RelatedTermType < Core::Node::Enum
    # The current term deprecates the related term.
    DEPRECATES = new("deprecates")

    # The current term supersedes the related term.
    SUPERSEDES = new("supersedes")

    # The current term is narrower in denotation than the related term.
    NARROWER = new("narrower")

    # The current term is broader in denotation than the related term.
    BROADER = new("broader")

    # The current term is equivalent in denotation than the related term.
    EQUIVALENT = new("equivalent")

    # The current term may be compared to the related term.
    COMPARE = new("compare")

    # The current term is understood in contrast to the related term.
    CONTRAST = new("contrast")

    # For a better understanding of the current term, one should also see the related term.
    SEE = new("see")
  end
end; end; end
