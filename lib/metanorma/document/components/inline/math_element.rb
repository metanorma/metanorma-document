# frozen_string_literal: true

require "mml"

module Metanorma
  module Document
    module Components
      module Inline
        # A MathML `<math>` element. Modeled via the mml gem's
        # `Mml::V3::Math`, which carries the MathML namespace and a full
        # MathML content model — no raw markup strings (project rule),
        # and the `xmlns` survives round-trips (previously the
        # raw-capture mapping dropped it, silently moving `<math>` into
        # the standoc namespace on serialize).
        #
        # Subclasses SemanticMathElement/RenderedMathElement stay as pure
        # markers so consumers can distinguish the canonical form from
        # the locale-rendered form via `is_a?`.
        class MathElement < Mml::V3::Math
        end
      end
    end
  end
end
