# frozen_string_literal: true

require "basic_document/idelements/media"

module Metanorma; module Document; module BasicDocument
  # Container for video content.
  class Video < Media
    register_element do
      # Alternative files to use as media.
      nodes :altsource, AltSource

      # Height of video. Can have "auto" as value.
      nodes :height, Integer

      # Width of video. Can have "auto" as value.
      nodes :width, Integer
    end
  end
end; end; end
