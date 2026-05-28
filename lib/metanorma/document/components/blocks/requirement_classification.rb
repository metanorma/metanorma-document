# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        class RequirementClassification < Lutaml::Model::Serializable
          attribute :tag, :string
          attribute :value, ClassificationValue

          xml do
            element "classification"
            map_element "tag", to: :tag
            map_element "value", to: :value
          end
        end
      end
    end
  end
end
