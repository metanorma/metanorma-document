# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class NoteDrop < BlockElementDrop
        def self.from_model(note, renderer:)
          id = renderer.safe_attr(note, :id)
          label = renderer.extract_block_label(note, "NOTE")

          content_parts = []
          if note.content && !note.content.empty?
            note.content.each { |para| content_parts << (renderer.render_paragraph(para) || "") }
          else
            inline = renderer.render_mixed_inline(note)
            content_parts << inline if inline
          end
          content_parts << (renderer.render_note_children(note) || "")
          content_html = content_parts.join

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
