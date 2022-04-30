# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Specification of (potentially document-specific) cross-references, to overwrite the
  # links within an SVG file, so that the SVG file can hyperlink to anchors within the document.
  class SvgTargetType < Core::Node
    include Core::Node::Custom
  end
end; end; end
