# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Change
      # Specification of the deletion of a data node in a BasicDocument.
      class NodeDelete < Metanorma::BasicDocument::Change::NodeChange
        attribute :hash_value, :string

        xml do
          element "node-delete"
          map_attribute "hash-value", to: :hash_value
        end
      end
    end
  end
end
