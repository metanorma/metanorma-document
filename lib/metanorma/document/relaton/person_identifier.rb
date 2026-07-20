# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # An identifier of a person according to an international identifier scheme.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Person::Identifier
      # maps a type attribute plus element content, not our type/value
      # attribute pair (no fixture coverage justifies a shape change).
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
