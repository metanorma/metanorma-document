# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Change
      # Specification of moving a particular node in a BasicDocument
      # to another location within the same BasicDocument.
      class NodeMove < Metanorma::BasicDocument::Change::NodeChange
        attribute :position_old, Metanorma::BasicDocument::ReferenceElements::ReferenceToIdElement
        attribute :position_new, Metanorma::BasicDocument::ReferenceElements::ReferenceToIdElement

        xml do
          element "node-move"
          map_element "position-old", to: :position_old
          map_element "position-new", to: :position_new
        end
      end
    end
  end
end
