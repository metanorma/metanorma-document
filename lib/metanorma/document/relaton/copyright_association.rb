# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The copyright status of a bibliographic item.
      class CopyrightOwner < Lutaml::Model::Serializable
        attribute :organization, Organization

        xml do
          element "owner"
          map_element "organization", to: :organization
        end
      end

      class CopyrightAssociation < Lutaml::Model::Serializable
        attribute :from, Metanorma::Document::Relaton::DateTime
        attribute :to, Metanorma::Document::Relaton::DateTime
        attribute :owner, CopyrightOwner, collection: true
        attribute :scope, :string

        xml do
          element "copyright"
          map_element "from", to: :from
          map_element "to", to: :to
          map_element "owner", to: :owner
          map_attribute "scope", to: :scope
        end
      end
    end
  end
end
