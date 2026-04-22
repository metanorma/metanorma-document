# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Gregorian date, as specified in <<iso8601>>.
      class Iso8601Date < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "iso8601-date"
          map_content to: :value
        end
      end
    end
  end
end
