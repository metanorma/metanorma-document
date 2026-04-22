# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Change
        # Possible actions that involve
        # modification of data elements at the node level within a
        # BasicDocument. Add/remove node; Move node.
        class NodeChange < Change
          xml do
            element "node-change"
          end
        end
      end
    end
  end
end
