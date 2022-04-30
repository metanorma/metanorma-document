# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # The notation used to mathematically format text.
  class StemType < Core::Node::Enum
    # MathML
    MATHML = new("MathML")

    # AsciiMath
    ASCIIML = new("AsciiML")

    # LaTeX
    LATEX = new("LaTeX")
  end
end; end; end
