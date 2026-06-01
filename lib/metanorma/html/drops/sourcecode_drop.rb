# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class SourcecodeDrop < BlockElementDrop
        attr_reader :lang, :name_html, :code_html

        def initialize(id: nil, lang: nil, name_html: nil, code_html: nil,
css_class: nil)
          @id = id
          @lang = lang
          @name_html = name_html
          @code_html = code_html
          @css_class = css_class
        end

        def self.from_model(sc, renderer:)
          id = renderer.safe_attr(sc, :id)
          lang = renderer.safe_attr(sc, :lang)

          name_html = if sc.name
                        renderer.render_inline_element(sc.name)
                      end

          code_text = if sc.body&.content
                        Array(sc.body.content).join
                      elsif sc.content
                        Array(sc.content).join
                      else
                        ""
                      end
          raw_text = code_text.gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&").gsub(
            "&quot;", "\""
          )

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
