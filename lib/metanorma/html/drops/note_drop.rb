# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class NoteDrop < BlockElementDrop
        LABEL_CLASS = "note-label"
        private_constant :LABEL_CLASS

        def self.from_model(note, renderer:)
          id = renderer.safe_attr(note, :id)
          label = renderer.extract_block_label(note, "NOTE")

          content_parts = []
          label_rendered = label.nil?

          if note.content && !note.content.empty?
            note.content.each do |para|
              if label_rendered
                content_parts << (renderer.render_paragraph(para) || "")
              else
                content_parts << (renderer.render_paragraph(para,
                                                            label: label,
                                                            label_class: LABEL_CLASS) || "")
                label_rendered = true
              end
            end
          else
            inline = renderer.render_mixed_inline(note)
            if inline
              if label_rendered
                content_parts << inline
              else
                content_parts << renderer.render_label_paragraph(inline,
                                                                 label: label,
                                                                 label_class: LABEL_CLASS)
                label_rendered = true
              end
            end
          end

          content_parts << (renderer.render_note_children(note) || "")

          if !label_rendered
            content_parts.unshift(renderer.render_label_paragraph("",
                                                                  label: label,
                                                                  label_class: LABEL_CLASS))
          end

          new(
            id: id,
            label_html: renderer.escape_html(label),
            content_html: content_parts.join,
            css_class: "note-block",
          )
        end
      end
    end
  end
end
