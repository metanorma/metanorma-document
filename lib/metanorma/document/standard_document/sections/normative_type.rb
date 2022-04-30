# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The force of a clause of text in a _StandardDocument_.
  class NormativeType < Core::Node::Enum
    # The content in this section has normative effect.
    NORMATIVE = new("normative")

    # The content in this section has informative effect.
    INFORMATIVE = new("informative")
  end
end; end; end
