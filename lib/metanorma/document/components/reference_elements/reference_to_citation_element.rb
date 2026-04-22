# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        # An external reference to a bibliographic entity.
        class ReferenceToCitationElement < Metanorma::Document::Components::ReferenceElements::ReferenceElement
          attribute :id, :string
          attribute :normative, :boolean
          attribute :cite_as, Metanorma::Document::Components::TextElements::TextElement,
                    collection: true
          attribute :bibitemid, :string
          attribute :citeas, :string
          attribute :locality_stack, Metanorma::Document::Relaton::LocalityStack,
                    collection: true

          xml do
            element "reference-to-citation-element"
            map_attribute "id", to: :id
            map_attribute "normative", to: :normative
            map_element "cite-as", to: :cite_as
            map_attribute "bibitemid", to: :bibitemid
            map_attribute "citeas", to: :citeas
            map_element "localityStack", to: :locality_stack
          end
        end
      end
    end
  end
end
