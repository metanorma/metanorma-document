# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Pre-formatted blocks are wrappers for text to be rendered with fixed-width typeface, and preserving
  # spaces including line breaks. They are intended for a restricted number of functions, most typically
  # ASCII Art (which is still in prominent use in some standards documents), and computer output. In
  # most cases, Sourcecode blocks are more appropriate in markup, as it is more clearly motivated
  # semantically.
  class LiteralBlock < Core::Node
    include Core::Node::Custom

    register_element "pre" do
      # Accessible description of the preformatted text.
      attribute :alt, String

      # The caption of the block.
      nodes :name, TextElement

      # The pre-formatted text presented in the block, as a single unformatted string. (Whitespace is
      # treated as significant.)
      attribute :content, String
    end
  end
end; end; end
