# frozen_string_literal: true

require "standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  # Wrapper around an SVG file, to update its hyperlinks with potentially document-specific
  # links, so that the SVG file can hyperlink to anchors within the document.
  class SvgMapBlock < StandardBlockNoNotes
  end
end; end; end
