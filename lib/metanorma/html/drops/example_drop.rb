# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class ExampleDrop < BlockElementDrop
        def self.from_model(example, renderer:)
          id = renderer.safe_attr(example, :id)
          label = renderer.extract_block_label(example, "EXAMPLE")

          content_html = renderer.capture_output do
            if example.paragraphs && !example.paragraphs.empty?
              example.paragraphs.each { |para| renderer.render_paragraph(para) }
            end
            example.ul&.each { |ul| renderer.render_unordered_list(ul) }
            example.ol&.each { |ol| renderer.render_ordered_list(ol) }
            example.dl&.each { |dl| renderer.render_definition_list(dl) }
            example.sourcecode&.each { |sc| renderer.render_sourcecode(sc) }
            example.table&.each { |t| renderer.render_table(t) }
            example.figure&.each { |f| renderer.render_figure(f) }
            example.quote&.each { |q| renderer.render_quote(q) }
            example.formula&.each { |f| renderer.render_formula(f) }
          end

          new(
            id: id,
            label_html: renderer.escape_html(label),
            content_html: content_html,
            css_class: "example",
          )
        end
      end
    end
  end
end
