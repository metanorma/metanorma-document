# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
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
