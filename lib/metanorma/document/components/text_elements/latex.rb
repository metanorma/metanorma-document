# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Mathematical text formatted in LaTeX.
        class Latex < StemValue
          attribute :value, :string

          xml do
            element "latex"
            map_content to: :value
          end
        end
      end
    end
  end
end
