# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # The notation used to mathematically format text.
        class StemType < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            element "stem-type"
            map_content to: :value

            def self.values
              %w[MathML AsciiML LaTeX]
            end
          end
        end
      end
    end
  end
end
