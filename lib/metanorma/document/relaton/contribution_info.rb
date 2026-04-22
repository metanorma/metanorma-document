# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Description of a contributor to the production of the bibliographic item.
      class ContributionInfo < Lutaml::Model::Serializable
        attribute :role, ContributorRole, collection: true
        attribute :organization, Organization
        attribute :person, Person

        xml do
          element "contributor"
          map_element "role", to: :role
          map_element "organization", to: :organization
          map_element "person", to: :person
        end
      end
    end
  end
end
