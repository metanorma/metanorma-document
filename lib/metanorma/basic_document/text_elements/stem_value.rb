# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # The content of mathematically formatted text.
      class StemValue < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "stem-value"
          map_content to: :value
        end
      end
    end
  end
end
