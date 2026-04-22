# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Blocks
      # Base class of blocks for a BasicDocument, omitting notes.
      class BasicBlockNoNotes < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :contrib_metadata,
                  Metanorma::BasicDocument::ContribMetadata::ContributionElementMetadata,
                  collection: true

        xml do
          element "basic-block-no-notes"
          map_attribute "id", to: :id
          map_element "contrib-metadata", to: :contrib_metadata
        end
      end
    end
  end
end
