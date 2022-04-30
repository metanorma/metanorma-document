# frozen_string_literal: true

require "metanorma/document/basic_document/textelements/stem_value"

module Metanorma; module Document; module BasicDocument
  # Mathematical text formatted in LaTeX.
  class LaTeX < StemValue
    register_element do
      # LaTeX content.
      attribute :value, String
    end
  end
end; end; end
