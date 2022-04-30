# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # `BasicElement` with an identifier, to be used in crossreferencing by Reference Elements. The
  # `IdElement` itself acts as a reference point, such as in a `SourcecodeBlock` for callout references
  # (the `IdElement` is the location), and for delimiting `ReviewComment` start/end places.
  class IdElement < Core::Node
  end
end; end; end
