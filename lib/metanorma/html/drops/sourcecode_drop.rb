# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class SourcecodeDrop < BlockElementDrop
        attr_reader :lang, :name_html, :code_html

        def self.from_model(sc, renderer:)
          id = renderer.safe_attr(sc, :id)
          lang = renderer.safe_attr(sc, :lang)

          name_html = if sc.name
                        renderer.capture_output { renderer.render_inline_element(sc.name) }
                      end

          code_text = if sc.body&.content
                        sc.body.content
                      elsif sc.content
                        sc.content
                      else
                        ""
                      end
          raw_text = code_text.gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&").gsub("&quot;", "\"")

          new(
            id: id,
            lang: lang,
            name_html: name_html,
            code_html: renderer.escape_html(raw_text),
            css_class: "sourcecode",
          )
        end
      end
    end
  end
end
