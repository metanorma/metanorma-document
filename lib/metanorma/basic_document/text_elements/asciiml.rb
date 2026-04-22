# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Mathematical text formatted in AsciiMath.
      class AsciiML < Metanorma::BasicDocument::TextElements::StemValue
        attribute :value, :string

        xml do
          element "asciiml"
          map_content to: :value
        end
      end
    end
  end
end
