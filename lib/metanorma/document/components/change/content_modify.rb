# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Change
        # Container for a multiple _ContentChangeAction_ data
        class ContentModify < ContentChange
          attribute :actions, ContentChangeAction, collection: true

          xml do
            element "content-modify"
            map_element "actions", to: :actions
          end
        end
      end
    end
  end
end
