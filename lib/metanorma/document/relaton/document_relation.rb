# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Relation between a bibliographic item and another bibliographic item.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Relation types
      # description as a singular sanitized LocalizedMarkedUpString (ours is
      # a FormattedString collection), bibitem as relaton's own ItemBase tree
      # (fixtures nest full Metanorma bibitems — fetched, multi-language
      # titles, typed uris, primary docidentifiers — modeled by our
      # BibliographicItem), and replaces the localityStack/
      # sourceLocalityStack-only shape with choice(locality|localityStack)
      # under different attribute names.
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
