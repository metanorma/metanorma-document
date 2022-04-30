# frozen_string_literal: true

require "standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  # Wrapper around an image file, to specify an image map, with areas of an image being hyperlinked.
  class ImageMapBlock < StandardBlockNoNotes
    register_element do
      # The location of the image file to be updated.
      attribute :source, String

      # Alternate text to be provided for the image file.
      attribute :alt, String

      # Areas of the image to be hyperlinked.
      nodes :area, ImageMapAreaType
    end
  end
end; end; end
