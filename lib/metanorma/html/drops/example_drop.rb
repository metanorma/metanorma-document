# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class ExampleDrop < BlockElementDrop
        def self.from_model(example, renderer:)
          id = renderer.safe_attr(example, :id)
          label = renderer.extract_block_label(example, "EXAMPLE")

          content_html = renderer.capture_output do
            renderer.render_block_children(example,
                                           children: BaseRenderer::BLOCK_CHILDREN)
          end

          new(
            id: id,
            label_html: renderer.escape_html(label),
            content_html: content_html,
            css_class: "example",
          )
        end
      end
    end
  end
end
