# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Project number with optional part attribute.
      class ProjectNumber < Lutaml::Model::Serializable
        attribute :part, :string
        attribute :amendment, :string
        attribute :origyr, :string
        attribute :value, :string

        xml do
          element "project-number"
          map_attribute "part", to: :part
          map_attribute "amendment", to: :amendment
          map_attribute "origyr", to: :origyr
          map_content to: :value
        end
      end

      # Structured identifier for an ISO document (project number, part, etc).
      class StructuredIdentifier < Lutaml::Model::Serializable
        attribute :project_number, ProjectNumber

        xml do
          element "structuredidentifier"
          map_element "project-number", to: :project_number
        end
      end
    end
  end
end
