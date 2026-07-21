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
            note.content.each do |para|
              content_parts << (renderer.render_paragraph(para) || "")
            end
          else
            inline = renderer.render_mixed_inline(note)
            content_parts << inline if inline
          end
          content_parts << (renderer.render_note_children(note) || "")
          content_html = content_parts.join
          # isodoc convention: the NOTE label opens the first paragraph
          # (<p><span class="note-label">NOTE</span> text…</p>), it does
          # not float outside it.
          label_html = %(<span class="note-label">#{renderer.escape_html(label)}</span>&nbsp;)
          content_html = inject_label(content_html, label_html)

          new(
            id: id,
            label_html: renderer.escape_html(label),
            content_html: content_html,
            css_class: "note-block",
          )
        end

        # Inserts the label markup right after the first <p> opening
        # tag; when the note has no paragraph, the label leads the
        # content instead.
        def self.inject_label(content_html, label_html)
          if content_html.match?(/<p(?:\s[^>]*)?>/)
            content_html.sub(/<p(?:\s[^>]*)?>/, "\\0#{label_html}")
          else
            label_html + content_html
          end
        end
      end
    end
  end
end
