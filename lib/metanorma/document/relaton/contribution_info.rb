# frozen_string_literal: true

require "relaton/bib"

module Metanorma
  module Document
    module Relaton
      # Description of a contributor to the production of the bibliographic item.
      # Inherits relaton-bib's Contributor (role + person/organization choice);
      # the three mappings are re-declared with Metanorma's richer model
      # classes (mixed-content role, presentation-aware person/organization).
      class ContributionInfo < ::Relaton::Bib::Contributor
        attribute :role, ContributorRole, collection: true
        attribute :organization, Organization
        attribute :person, Person

        xml do
          map_element "role", to: :role
          map_element "organization", to: :organization
          map_element "person", to: :person
        end
      end
    end
  end
end
