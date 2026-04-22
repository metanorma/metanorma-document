# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Mathematical text formatted in LaTeX.
      class LaTeX < Metanorma::BasicDocument::TextElements::StemValue
        attribute :value, :string

        xml do
          element "latex"
          map_content to: :value
        end
      end
    end
  end
end
