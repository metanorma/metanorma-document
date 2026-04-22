# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Change
        # Specification of moving a particular node in a BasicDocument
        # to another location within the same BasicDocument.
        class NodeMove < NodeChange
          attribute :position_old, Metanorma::Document::Components::ReferenceElements::ReferenceToIdElement
          attribute :position_new, Metanorma::Document::Components::ReferenceElements::ReferenceToIdElement

          xml do
            element "node-move"
            map_element "position-old", to: :position_old
            map_element "position-new", to: :position_new
          end
        end
      end
    end
  end
end
