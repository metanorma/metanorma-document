# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module DataTypes
      # Container for URIs, as defined by <<rfc3986>>.
      class Uri < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "uri"
          map_content to: :value
        end
      end
    end
  end
end
