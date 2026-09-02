# frozen_string_literal: true

module Metanorma
  module Html
    # Shared forwarding methods for narrowing wrappers around a
    # renderer. Both RendererContext (used by Drop factories) and
    # Component::Base (used by Component renderers) include this
    # module so the shared forwarding surface is declared in one
    # place. Adding a new shared method is one edit here, not two.
    #
    # Per-class-specific forwarders stay declared in each wrapper.
    module RendererDelegation
      def safe_attr(...)        = @renderer.safe_attr(...)
      def escape_html(...)      = @renderer.escape_html(...)
      def extract_block_label(...) = @renderer.extract_block_label(...)
      def extract_plain_text(...) = @renderer.extract_plain_text(...)
      def render_mixed_inline(...) = @renderer.render_mixed_inline(...)
      def render_liquid(...) = @renderer.render_liquid(...)
    end
  end
end
