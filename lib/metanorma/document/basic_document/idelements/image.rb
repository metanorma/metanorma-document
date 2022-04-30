# frozen_string_literal: true

require "basic_document/idelements/media"

module Metanorma; module Document; module BasicDocument
  # Container for image content.
  class Image < Media
    register_element do
      # Height of image. Can have "auto" as value.
      nodes :height, Integer

      # Width of image. Can have "auto" as value.
      nodes :width, Integer
    end
  end
end; end; end