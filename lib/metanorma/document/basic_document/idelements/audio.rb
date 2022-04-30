# frozen_string_literal: true

require "basic_document/idelements/media"

module Metanorma; module Document; module BasicDocument
  # Container for audio content.
  class Audio < Media
    register_element "audio" do
      # Alternative files to use as media.
      nodes :altsource, AltSource
    end
  end
end; end; end
