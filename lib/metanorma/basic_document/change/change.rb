# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Change
      # Specification of an update action to be performed incrementally on an element within a
      # BasicDocument.
      class Change < Lutaml::Model::Serializable
        attribute :target, Metanorma::BasicDocument::ReferenceElements::ReferenceToIdElement
        attribute :identifier, Metanorma::BasicDocument::Change::UniqueIdentifier
        attribute :parent_identifier, Metanorma::BasicDocument::Change::UniqueIdentifier
        attribute :contrib_metadata, Metanorma::BasicDocument::ContribMetadata::ContributionElementMetadata,
                  collection: true

        xml do
          element "change"
          map_element "target", to: :target
          map_element "identifier", to: :identifier
          map_element "parent-identifier", to: :parent_identifier
          map_element "contrib-metadata", to: :contrib_metadata
        end
      end
    end
  end
end
