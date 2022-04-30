# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Orientation of pages in a section of text in paged media.
  class OrientationType < Core::Node::Enum
    # This page should be rendered in portrait layout in a paged medium.
    PORTRAIT = new("portrait")

    # This page should be rendered in landscape layout in a paged medium.
    LANDSCAPE = new("landscape")
  end
end; end; end
