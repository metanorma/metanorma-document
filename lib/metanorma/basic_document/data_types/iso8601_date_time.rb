# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module DataTypes
      # Gregorian date and time, as specified in <<iso8601>>.
      class Iso8601DateTime < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "iso8601-date-time"
          map_content to: :value
        end
      end
    end
  end
end
