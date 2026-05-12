# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class AdmonitionDrop < BlockElementDrop
        def self.from_model(admonition, renderer:)
          type = renderer.safe_attr(admonition, :type) || "note"
          id = renderer.safe_attr(admonition, :id)

          content_html = renderer.capture_output do
            renderer.render_block_children(admonition,
                                           children: BaseRenderer::SIMPLE_CHILDREN)
          end

          new(
            id: id,
            type: type,
            label_html: renderer.escape_html(type.capitalize),
            content_html: content_html,
            css_class: "admonition #{type}",
          )
        end
      end
    end
  end
end
