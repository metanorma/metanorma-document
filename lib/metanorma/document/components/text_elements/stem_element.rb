# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Mathematically formatted text.
        class StemElement < TextElement
          attribute :id, :string
          attribute :stem_type, :string
          attribute :block_attr, :string
          attribute :number_format, :string
          attribute :math, Mathml
          attribute :asciimath, Asciiml
          attribute :latexmath, LatexmathElement

          xml do
            element "stem"
            map_attribute "id", to: :id
            map_attribute "type", to: :stem_type
            map_attribute "block", to: :block_attr
            map_attribute "number-format", to: :number_format
            map_element "math", to: :math
            map_element "asciimath", to: :asciimath
            map_element "latexmath", to: :latexmath
          end
        end
      end
    end
  end
end
