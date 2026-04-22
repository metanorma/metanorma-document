# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Terms
      # Definition of a term.
      class TermDefinition < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :semx_id, :string
        attribute :verbal_definition, VerbalDefinition

        xml do
          element "definition"
          map_attribute "id", to: :id
          map_attribute "semx-id", to: :semx_id
          map_element "verbal-definition", to: :verbal_definition
        end
      end
    end
  end
end
