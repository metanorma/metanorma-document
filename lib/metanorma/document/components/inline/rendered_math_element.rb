# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Math content inside an `<fmt-stem><semx>` rendered-display
        # element. Represents the locale-rendered form of the math —
        # decimal commas, thousands separators, locale-specific
        # digit grouping.
        #
        # Subclass of `MathElement` so consumers that don't care about the
        # distinction continue to work via the base class. Consumers that
        # need to distinguish semantic from rendered forms use
        # `math.is_a?(RenderedMathElement)` vs `math.is_a?(SemanticMathElement)`.
        class RenderedMathElement < MathElement
        end
      end
    end
  end
end
