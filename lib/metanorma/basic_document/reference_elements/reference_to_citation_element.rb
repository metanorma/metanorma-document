# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ReferenceElements
      # An external reference to a bibliographic entity.
      class ReferenceToCitationElement < Metanorma::BasicDocument::ReferenceElements::ReferenceElement
        attribute :normative, :boolean
        attribute :cite_as,
                  Metanorma::BasicDocument::TextElements::TextElement, collection: true

        xml do
          element "reference-to-citation-element"
          map_attribute "normative", to: :normative
          map_element "cite-as", to: :cite_as
        end
      end
    end
  end
end
