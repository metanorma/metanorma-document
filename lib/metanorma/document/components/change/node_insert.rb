# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Change
        # Specification of the insertion
        # of a data node in a BasicDocument.
        class NodeInsert < NodeChange
          attribute :content, Metanorma::Document::Components::EmptyElements::BasicElement

          xml do
            element "node-insert"
            map_element "content", to: :content
          end
        end
      end
    end
  end
end
