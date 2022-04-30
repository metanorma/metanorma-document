# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The type of series description given.
  class SeriesTypeType < Core::Node::Enum
    # Default type: The current, authoritative series description.
    MAIN = new("main")

    # An alternative, potentially historical series description.
    ALT = new("alt")
  end
end; end; end
