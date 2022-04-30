# frozen_string_literal: true

require "standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  # Wrapper around an SVG file, to update its hyperlinks with potentially document-specific
  # links, so that the SVG file can hyperlink to anchors within the document.
  class SvgMapBlock < StandardBlockNoNotes
    register_element do
      # The location of the SVG file to be updated.
      attribute :source, String

      # Alternate text to be provided for the SVG file.
      attribute :alt, String

      # Specification of the cross-references to update the SVG file with.
      nodes :target, SvgTargetType
    end
  end
end; end; end
