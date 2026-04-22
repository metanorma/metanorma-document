# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Change
      # Specification of the insertion
      # of a data node in a BasicDocument.
      class NodeInsert < Metanorma::BasicDocument::Change::NodeChange
        attribute :content, Metanorma::BasicDocument::EmptyElements::BasicElement

        xml do
          element "node-insert"
          map_element "content", to: :content
        end
      end
    end
  end
end
