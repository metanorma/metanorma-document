# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 has no owner
      # wrapper (Copyright maps owner directly to ContributionInfo); the
      # wrapper is kept for consumer compatibility.
      class CopyrightOwner < Lutaml::Model::Serializable
        attribute :organization, Organization

        xml do
          element "owner"
          map_element "organization", to: :organization
        end
      end
    end
  end
end
