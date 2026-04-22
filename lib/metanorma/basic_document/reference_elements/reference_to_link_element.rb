# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ReferenceElements
      # A reference to an external document or resource.
      class ReferenceToLinkElement < Metanorma::BasicDocument::ReferenceElements::ReferenceElement
        attribute :target, :string

        xml do
          element "reference-to-link-element"
          map_attribute "target", to: :target
        end
      end
    end
  end
end
