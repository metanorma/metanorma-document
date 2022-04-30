# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # The alignment of the paragraph against the margins of the document.
  class TextAlignment < Core::Node::Enum
    # Left alignment.
    LEFT = new("left")

    # Center alignment.
    CENTER = new("center")

    # Right alignment.
    RIGHT = new("right")

    # Justified alignment.
    JUSTIFIED = new("justified")
  end
end; end; end
