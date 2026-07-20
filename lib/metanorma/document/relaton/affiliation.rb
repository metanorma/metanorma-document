# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The affiliation of a person with an organization.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Affiliation
      # sanitizes description (LocalizedMarkedUpString strips semx/span/fmt-*)
      # and types name/organization as relaton's own classes.
      class Affiliation < Lutaml::Model::Serializable
        attribute :name, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :description,
                  Metanorma::Document::Components::DataTypes::FormattedString, collection: true
        attribute :organization, Organization

        xml do
          element "affiliation"
          map_element "name", to: :name
          map_element "description", to: :description
          map_element "organization", to: :organization
        end
      end
    end
  end
end
