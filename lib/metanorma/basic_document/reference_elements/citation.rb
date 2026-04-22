# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ReferenceElements
      # Representation of a citation of a bibliographic item, typically within a document.
      class Citation < Lutaml::Model::Serializable
        attribute :date, :string
        attribute :bib_locality, Metanorma::Document::Relaton::BibItemLocality,
                  collection: true
        attribute :bib_locality_stack,
                  Metanorma::Document::Relaton::LocalityStack, collection: true
        attribute :bib_item, Metanorma::BasicDocument::BibData::BibliographicItem

        xml do
          element "citation"
          map_attribute "date", to: :date
          map_element "bib-locality", to: :bib_locality
          map_element "bib-locality-stack", to: :bib_locality_stack
          map_element "bib-item", to: :bib_item
        end
      end
    end
  end
end
