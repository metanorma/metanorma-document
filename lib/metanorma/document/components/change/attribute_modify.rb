# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Change
        # A container for a multiple _AttributeChangeAction_ data.
        # Add attribute; Remove attribute; Modify attribute.
        class AttributeModify < ContentModify
          attribute :actions, AttributeChangeAction, collection: true

          xml do
            element "attribute-modify"
            map_element "actions", to: :actions
          end
        end
      end
    end
  end
end
