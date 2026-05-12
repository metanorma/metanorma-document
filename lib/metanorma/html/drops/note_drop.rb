# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class NoteDrop < BlockElementDrop
        def self.from_model(note, renderer:)
          id = renderer.safe_attr(note, :id)
          label = renderer.extract_block_label(note, "NOTE")

          content_html = renderer.capture_output do
            if note.content && !note.content.empty?
              note.content.each { |para| renderer.render_paragraph(para) }
            else
              renderer.render_mixed_inline(note)
            end
            renderer.render_block_children(note,
                                           children: BaseRenderer::NOTE_CHILDREN)
          end

          new(
            id: id,
            label_html: renderer.escape_html(label),
            content_html: content_html,
            css_class: "note-block",
          )
        end
      end
    end
  end
end
