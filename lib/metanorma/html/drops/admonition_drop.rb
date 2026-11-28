# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class AdmonitionDrop < BlockElementDrop
        def self.from_model(admonition, renderer:)
          type = renderer.safe_attr(admonition, :type) || "note"
          id = renderer.safe_attr(admonition, :id)

          content_html = renderer.render_admonition_children(admonition) || ""
          # The presentation label (fmt-name) is authoritative — native
          # output shows it verbatim ("IMPORTANT"); fall back to the
          # admonition type only when the block carries no label.
          fmt_name = renderer.safe_attr(admonition, :fmt_name)
          label_html = if fmt_name
                         renderer.render_inline_element(fmt_name).to_s
                       else
                         renderer.escape_html(type.capitalize)
                       end

          new(
            id: id,
            type: type,
            label_html: label_html,
            content_html: content_html,
            css_class: "admonition #{type}",
          )
        end
      end
    end
  end
end
