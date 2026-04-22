# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Relation between a bibliographic item and another bibliographic item.
      class DocumentRelation < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :description,
                  Metanorma::Document::Components::DataTypes::FormattedString, collection: true
        attribute :bibitem, Metanorma::Document::Components::BibData::BibliographicItem
        attribute :bib_locality, LocalityStack, collection: true
        attribute :bib_source_locality, LocalityStack, collection: true

        xml do
          element "relation"
          map_attribute "type", to: :type
          map_element "description", to: :description
          map_element "bibitem", to: :bibitem
          map_element "localityStack", to: :bib_locality
          map_element "sourceLocalityStack", to: :bib_source_locality
        end
      end
    end
  end
end
