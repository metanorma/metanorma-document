# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class FigureDrop < BlockElementDrop
        attr_reader :image_html, :caption_html, :key_html, :sub_figures_html

        def initialize(id: nil, image_html: nil, caption_html: nil, key_html: nil,
                       sub_figures_html: nil, css_class: nil)
          @id = id
          @image_html = image_html
          @caption_html = caption_html
          @key_html = key_html
          @sub_figures_html = sub_figures_html
          @css_class = css_class
        end

        def self.from_model(figure, renderer:)
          id = renderer.safe_attr(figure, :id)
          fig_name = renderer.safe_attr(figure,
                                        :fmt_name) || renderer.safe_attr(
                                          figure, :name
                                        )
          if id && fig_name
            renderer.register_figure_entry(id: id,
                                           text: renderer.extract_plain_text(fig_name))
          end

          image_html = if figure.image
                         renderer.render_image(figure.image)
                       elsif renderer.safe_attr(figure, :source)
                         src = renderer.safe_attr(figure, :source)
                         renderer.render_liquid("_image.html.liquid",
                                                "attrs" => %( src="#{renderer.escape_html(src)}"))
                       end

          caption_html = if fig_name || renderer.safe_attr(figure, :name)
                           el = renderer.safe_attr(figure,
                                                   :fmt_name) || figure.name
                           renderer.render_inline_element(el)
                         end

          sub_figures_parts = []
          figure.figure&.each { |sub| sub_figures_parts << (renderer.render_figure(sub) || "") }
          sub_figures_html = sub_figures_parts.join

          key_parts = []
          renderer.safe_attr(figure, :note)&.each do |n|
            key_parts << (renderer.render_note(n) || "")
          end
          renderer.safe_attr(figure, :dl)&.then do |dl|
            key_parts << (renderer.render_definition_list(dl) || "")
          end
          key_html = key_parts.join

          new(
            id: id,
            image_html: image_html,
            caption_html: caption_html,
            key_html: key_html,
            sub_figures_html: sub_figures_html,
            css_class: "figure",
          )
        end
      end
    end
  end
end
