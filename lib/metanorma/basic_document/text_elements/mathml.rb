# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Mathematical text formatted in MathML.
      class MathML < Metanorma::BasicDocument::TextElements::StemValue
        attribute :value, BasicObject

        xml do
          element "mathml"
          map_content to: :value
        end
      end
    end
  end
end
