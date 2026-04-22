# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ContribMetadata
      # Identifier of hash algorithm defined in ISO 10118.
      class Iso10118Oid < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "iso10118-oid"
          map_content to: :value
        end
      end
    end
  end
end
