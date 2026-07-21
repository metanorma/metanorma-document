# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class ExampleDrop < BlockElementDrop
        def self.from_model(example, renderer:)
          id = renderer.safe_attr(example, :id)
          label = renderer.extract_block_label(example, "EXAMPLE")

          content_html = renderer.render_full_block_children(example) || ""
          # Same convention as notes: the EXAMPLE label opens the first
          # paragraph rather than floating outside it.
          label_html = %(<span class="example-label">#{renderer.escape_html(label)}</span>&nbsp;)
          content_html = NoteDrop.inject_label(content_html, label_html)

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
