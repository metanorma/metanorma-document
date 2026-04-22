# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The international identifier scheme for the identifier of a person.
      class PersonalIdentifierType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "personal-identifier-type"
          map_content to: :value
        end

        def self.values
          %w[Isni Orcid Uri]
        end
      end
    end
  end
end
