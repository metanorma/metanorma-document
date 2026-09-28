# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class SourcecodeDrop < BlockElementDrop
        attr_reader :lang, :name_html, :code_html, :annotations_html

        def initialize(id: nil, lang: nil, name_html: nil, code_html: nil,
css_class: nil, annotations_html: nil)
          @id = id
          @lang = lang
          @name_html = name_html
          @code_html = code_html
          @css_class = css_class
          @annotations_html = annotations_html
        end

        def self.from_model(sc, renderer:)
          id = renderer.safe_attr(sc, :id)
          lang = renderer.safe_attr(sc, :lang)

          name_html = if sc.name
                        renderer.render_inline_element(sc.name)
                      end

          code_text = if sc.body
                        sc.body.decoded_content
                      elsif sc.content
                        Array(sc.content).join
                      else
                        ""
                      end

          new(
            id: id,
            lang: lang,
            name_html: name_html,
            code_html: renderer.escape_html(code_text),
            css_class: "sourcecode",
            annotations_html: annotations_key_html(sc, renderer),
          )
        end

        # Callout annotations render as a Key definition list under the
        # code, like the native isodoc figdl block. Callouts are numbered
        # in document order.
        def self.annotations_key_html(sc, renderer)
          annotations = Array(renderer.safe_attr(sc, :callout_annotations))
          return nil if annotations.empty?

          rows = annotations.each_with_index.map do |ann, i|
            dd = Array(ann.p).map { |para| renderer.render_paragraph(para) }.join
            %(<dt><span class="c">#{i + 1}</span></dt><dd>#{dd}</dd>)
          end
          rows.join
        end
      end
    end
  end
end
