# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Type of linguistic form used as designation.
  class ExpressionType < Core::Node::Enum
    # The form is a prefix.
    PREFIX = new("prefix")

    # The form is a suffix.
    SUFFIX = new("suffix")

    # The form is an abbreviation.
    ABBREVIATION = new("abbreviation")

    # The form is a self-standing linguistic expression.
    FULL = new("full")
  end
end; end; end
