# frozen_string_literal: true

module Metanorma; module Document; module IsoDocument
  # Title of ISO/IEC document.
  class IsoLocalizedTitle < Core::Node
    include Core::Node::Custom

    register_element do
      # Introductory component of title.
      node :title_intro, BasicDocument::FormattedString

      # Main component of title.
      node :title_main, BasicDocument::FormattedString

      # Title of document part, if applicable.
      node :title_part, BasicDocument::FormattedString
    end
  end
end; end; end
