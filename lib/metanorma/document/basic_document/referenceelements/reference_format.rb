# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # The type of Reference Element, prescribing how it is to be rendered.
  class ReferenceFormat < Core::Node::Enum
    # Reference to an external document.
    EXTERNAL = new("external")

    # Reference to another element in the same document.
    INLINE = new("inline")

    # Inline reference to a block to be rendered as a footnote.
    FOOTNOTE = new("footnote")

    # Inline reference to a block to be referenced as a sourcecode callout.
    CALLOUT = new("callout")
  end
end; end; end
