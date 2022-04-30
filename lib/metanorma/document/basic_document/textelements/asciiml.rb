# frozen_string_literal: true

require "basic_document/textelements/stem_value"

module Metanorma; module Document; module BasicDocument
  # Mathematical text formatted in AsciiMath.
  class AsciiML < StemValue
    register_element do
      # AsciiMath content.
      attribute :value, String
    end
  end
end; end; end
