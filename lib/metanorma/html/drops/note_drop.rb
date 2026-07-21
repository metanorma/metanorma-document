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
        #
        # Uses linear string scanning rather than a regex so that
        # adversarial or malformed input (e.g. an unterminated `<p `
        # sequence) cannot trigger polynomial backtracking.
        def self.inject_label(content_html, label_html)
          injection_point = first_paragraph_open_tag_end(content_html)
          return label_html + content_html if injection_point.nil?

          content_html.dup.insert(injection_point, label_html)
        end

        # Returns the index immediately AFTER the '>' that closes the
        # first `<p ...>` opening tag in +content_html+, or nil if the
        # string has no `<p` token. Search is linear: find the first
        # occurrence of "<p" (optionally followed by attributes up to
        # the next '>').
        def self.first_paragraph_open_tag_end(content_html)
          p_start = content_html.index("<p")
          return nil if p_start.nil?
          return nil if p_start + 2 >= content_html.length

          tag_end = content_html.index(">", p_start + 2)
          return nil if tag_end.nil?

          tag_end + 1
        end
      end
    end
  end
end
