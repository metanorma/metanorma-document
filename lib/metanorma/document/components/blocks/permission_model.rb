# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        class PermissionModel < RequirementBase
          xml do
            element "permission"
            map_attribute "id", to: :id
            map_attribute "model", to: :model
            map_attribute "obligation", to: :obligation
            map_attribute "type", to: :type
            map_attribute "anchor", to: :anchor
            map_element "subject", to: :subject
            map_element "classification", to: :classification
            map_element "description", to: :description
            map_element "inherit", to: :inherit
            map_element "requirement", to: :requirement
            map_element "recommendation", to: :recommendation
            map_element "permission", to: :permission
            map_element "example", to: :example
          end
        end
      end
    end
  end
end
