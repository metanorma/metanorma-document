# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module EmptyElements
      # Container of inline content in BasicDocument.
      class BasicElement < Lutaml::Model::Serializable
        attribute :contrib_metadata, Metanorma::BasicDocument::ContribMetadata::ContributionElementMetadata,
                  collection: true

        xml do
          element "basic-element"
          map_element "contrib-metadata", to: :contrib_metadata
        end
      end
    end
  end
end
