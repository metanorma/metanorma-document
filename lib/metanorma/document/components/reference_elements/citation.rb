# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        # Representation of a citation of a bibliographic item, typically within a document.
        class Citation < Lutaml::Model::Serializable
          attribute :bibitemid, :string
          attribute :date, :string
          attribute :type, :string
          attribute :citeas, :string
          attribute :bib_locality, Metanorma::Document::Relaton::BibItemLocality,
                    collection: true
          attribute :bib_locality_stack, Metanorma::Document::Relaton::LocalityStack,
                    collection: true
          attribute :locality_stack, Metanorma::Document::Relaton::LocalityStack,
                    collection: true
          attribute :bib_item, Metanorma::Document::Components::BibData::BibliographicItem
          attribute :display_text, "Metanorma::Document::Components::Inline::DisplayTextElement"

          xml do
            element "citation"
            map_attribute "bibitemid", to: :bibitemid
            map_attribute "date", to: :date
            map_attribute "type", to: :type
            map_attribute "citeas", to: :citeas
            map_element "bib-locality", to: :bib_locality
            map_element "bib-locality-stack", to: :bib_locality_stack
            map_element "localityStack", to: :locality_stack
            map_element "bib-item", to: :bib_item
            map_element "display-text", to: :display_text
          end
        end
      end
    end
  end
end
