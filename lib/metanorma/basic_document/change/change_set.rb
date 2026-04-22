# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Change
      # A collection of _Change_ data, specifying the document they should be applied to.
      class ChangeSet < Lutaml::Model::Serializable
        attribute :changes, Metanorma::BasicDocument::Change::Change,
                  collection: true
        attribute :document_identifier, Metanorma::BasicDocument::Change::UniqueIdentifier

        xml do
          element "change-set"
          map_element "changes", to: :changes
          map_element "document-identifier", to: :document_identifier
        end
      end
    end
  end
end
