# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Terms
      # Modification element in term source, containing paragraphs.
      class TermModification < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :p, RawParagraph, collection: true

        xml do
          element "modification"
          map_attribute "id", to: :id
          map_element "p", to: :p
        end
      end

      # Source of a term definition, with optional modification info.
      class TermSource < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :status, :string
        attribute :type, :string
        attribute :origin, TermOrigin
        attribute :modification, TermModification

        xml do
          element "source"
          map_attribute "id", to: :id
          map_attribute "status", to: :status
          map_attribute "type", to: :type
          map_element "origin", to: :origin
          map_element "modification", to: :modification
        end
      end

      # Same structure as TermSource but mapped to the <termsource> element.
      class TermsourceElement < TermSource
        xml do
          element "termsource"
          map_attribute "id", to: :id
          map_attribute "status", to: :status
          map_attribute "type", to: :type
          map_element "origin", to: :origin
          map_element "modification", to: :modification
        end
      end
    end
  end
end
