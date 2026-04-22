# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ReferenceElements
      # An internal reference to an element of the current document.
      class ReferenceToIdElement < Metanorma::BasicDocument::ReferenceElements::ReferenceElement
        attribute :target, Metanorma::BasicDocument::IdElements::IdElement

        xml do
          element "reference-to-id-element"
          map_element "target", to: :target
        end
      end
    end
  end
end
