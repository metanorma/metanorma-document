# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        class RecommendationModel < RequirementBase
          xml do
            element "recommendation"
            map_attribute "id", to: :id
            map_attribute "model", to: :model
            map_attribute "obligation", to: :obligation
            map_attribute "type", to: :type
            map_attribute "anchor", to: :anchor
            map_element "subject", to: :subject
            map_element "classification", to: :classification
            map_element "description", to: :description
            map_element "identifier", to: :identifier
            map_element "title", to: :title
            map_element "specification", to: :specification
            map_element "measurement-target", to: :measurement_target
            map_element "verification", to: :verification
            map_element "import", to: :import
            map_element "inherit", to: :inherit
            map_element "fmt-name", to: :fmt_name
            map_element "fmt-xref-label", to: :fmt_xref_label
            map_element "fmt-provision", to: :fmt_provision
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
