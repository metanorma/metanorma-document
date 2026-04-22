# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Change
        # Possible actions
        # that involve modification of content within a BasicDocument
        # data element.
        # Add text; Delete text; Modify text.
        class ContentChange < Change
          xml do
            element "content-change"
          end
        end
      end
    end
  end
end
