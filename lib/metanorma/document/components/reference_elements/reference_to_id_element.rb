# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        # An internal reference to an element of the current document.
        class ReferenceToIdElement < ReferenceElement
          attribute :target, Metanorma::Document::Components::IdElements::IdElement

          xml do
            element "reference-to-id-element"
            map_element "target", to: :target
          end
        end
      end
    end
  end
end
