# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Wrapper around an SVG file, to update its hyperlinks with potentially document-specific
  # links, so that the SVG file can hyperlink to anchors within the document.
  class SvgMapBlock < Core::Node
  end
end; end; end
