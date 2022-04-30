# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Specification of (potentially document-specific) cross-references, to overwrite the
  # links within an SVG file, so that the SVG file can hyperlink to anchors within the document.
  class SvgTargetType < Core::Node
    include Core::Node::Custom

    register_element do
      # The value of the `href` attribute in the SVG file to be overwritten.
      attribute :href, String

      # The cross-reference or hyperlink, whose value is to overwrite the value of the `href` attribute in
      # the SVG file.
      node :reference_element, BasicDocument::ReferenceElement
    end
  end
end; end; end
