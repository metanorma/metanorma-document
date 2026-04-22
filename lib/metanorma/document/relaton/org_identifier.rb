# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # An identifier of an organization according to an international identifier scheme.
      class OrgIdentifier < Lutaml::Model::Serializable
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
