# frozen_string_literal: true

require "metanorma/document/basic_document/textelements/stem_value"

module Metanorma; module Document; module BasicDocument
  # Mathematical text formatted in MathML.
  class MathML < StemValue
    register_element do
      # MathML content.
      node :value, BasicObject # But actually: MathMLValue
    end
  end
end; end; end
