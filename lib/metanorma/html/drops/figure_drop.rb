# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class FigureDrop < BlockElementDrop
        attr_reader :image_html, :caption_html, :key_html, :sub_figures_html

        def self.from_model(figure, renderer:)
          id = renderer.safe_attr(figure, :id)
          fig_name = renderer.safe_attr(figure, :fmt_name) || renderer.safe_attr(figure, :name)
          if id && fig_name
            renderer.register_figure_entry(id: id, text: renderer.extract_plain_text(fig_name))
          end

          image_html = renderer.capture_output do
            if figure.image
              renderer.render_image(figure.image)
            elsif renderer.safe_attr(figure, :source)
              src = renderer.safe_attr(figure, :source)
              @output << %(<img src="#{renderer.escape_html(src)}" />)
            end
          end

          caption_html = if fig_name || renderer.safe_attr(figure, :name)
                           renderer.capture_output do
                             el = renderer.safe_attr(figure, :fmt_name) || figure.name
                             renderer.render_inline_element(el)
                           end
                         end

          sub_figures_html = renderer.capture_output do
            figure.figure&.each { |sub| renderer.render_figure(sub) }
          end

          key_html = renderer.capture_output do
            renderer.safe_attr(figure, :note)&.each { |n| renderer.render_note(n) }
            renderer.safe_attr(figure, :dl)&.then { |dl| renderer.render_definition_list(dl) }
          end

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
