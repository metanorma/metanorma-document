# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # The notation used to mathematically format text.
      class StemType < Lutaml::Model::Serializable
        attribute :value, :string, values: %w[MathML AsciiML LaTeX]

        xml do
          element "stem-type"
          map_content to: :value
        end
      end
    end
  end
end
