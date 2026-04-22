# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The type of series description given.
      class SeriesTypeType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "series-type-type"
          map_content to: :value
        end

        def self.values
          %w[main alt]
        end
      end
    end
  end
end
