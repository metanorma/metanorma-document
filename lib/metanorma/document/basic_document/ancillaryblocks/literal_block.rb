# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Pre-formatted blocks are wrappers for text to be rendered with fixed-width typeface, and preserving
  # spaces including line breaks. They are intended for a restricted number of functions, most typically
  # ASCII Art (which is still in prominent use in some standards documents), and computer output. In
  # most cases, Sourcecode blocks are more appropriate in markup, as it is more clearly motivated
  # semantically.
  class LiteralBlock < Core::Node
  end
end; end; end
