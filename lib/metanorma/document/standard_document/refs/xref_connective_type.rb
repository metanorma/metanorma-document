# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Connective linking the current cross-reference target to its predecessor.
  class XrefConnectiveType < Core::Node::Enum
    # and
    AND = new("and")

    # or
    OR = new("or")

    # from, in from-to pair
    FROM = new("from")

    # to, in from-to pair
    TO = new("to")
  end
end; end; end
