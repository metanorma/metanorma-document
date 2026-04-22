# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module IdElements
      # `BasicElement` with an identifier, to be used in crossreferencing by Reference Elements. The
      # `IdElement` itself acts as a reference point, such as in a `SourcecodeBlock` for callout references
      # (the `IdElement` is the location), and for delimiting `ReviewComment` start/end places.
      class IdElement < Metanorma::BasicDocument::EmptyElements::BasicElement
        attribute :id, :string

        xml do
          element "id-element"
          map_attribute "id", to: :id
        end
      end
    end
  end
end
