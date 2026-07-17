# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Math content inside a semantic `<stem>` element. Represents the
        # canonical form of the math — decimal periods, no locale-specific
        # thousands separators.
        #
        # Subclass of `MathElement` so consumers that don't care about the
        # distinction continue to work via the base class. Consumers that
        # need to distinguish semantic from rendered forms use
        # `math.is_a?(SemanticMathElement)` vs `math.is_a?(RenderedMathElement)`.
        class SemanticMathElement < MathElement
        end
      end
    end
  end
end
