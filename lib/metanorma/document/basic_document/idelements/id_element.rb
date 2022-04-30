# frozen_string_literal: true

require "metanorma/document/basic_document/emptyelements/basic_element"

module Metanorma; module Document; module BasicDocument
  # `BasicElement` with an identifier, to be used in crossreferencing by Reference Elements. The
  # `IdElement` itself acts as a reference point, such as in a `SourcecodeBlock` for callout references
  # (the `IdElement` is the location), and for delimiting `ReviewComment` start/end places.
  class IdElement < BasicElement
    register_element do
      # Identifier of BasicElement.
      attribute :id, String
    end
  end
end; end; end
