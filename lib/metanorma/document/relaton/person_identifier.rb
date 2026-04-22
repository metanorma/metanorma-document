# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # An identifier of a person according to an international identifier scheme.
      class PersonIdentifier < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :value, :string

        xml do
          map_attribute "type", to: :type
          map_attribute "value", to: :value
        end
      end
    end
  end
end
