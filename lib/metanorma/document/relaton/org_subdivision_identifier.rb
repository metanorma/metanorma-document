# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # An identifier of an organization subdivision.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1
      # OrganizationType::Identifier lacks the @id attribute carried by fixtures.
      class OrgSubdivisionIdentifier < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :type, :string
        attribute :value, :string

        xml do
          map_attribute "id", to: :id
          map_attribute "type", to: :type
          map_content to: :value
        end
      end
    end
  end
end
