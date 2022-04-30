# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The type of the managed term in the present context.
  class TermSourceType < Core::Node::Enum
    # The managed term is authoritative in the present context.
    AUTHORITATIVE = new("authoritative")

    # The managed term constitutes lineage in the present context.
    LINEAGE = new("lineage")
  end
end; end; end
