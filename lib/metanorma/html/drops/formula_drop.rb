# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class FormulaDrop < BlockElementDrop
        attr_reader :stem_html, :where_html, :number_html

        def self.from_model(formula, renderer:)
          id = renderer.safe_attr(formula, :id)

          stem_html = renderer.capture_output do
            renderer.render_stem_content(formula.stem) if formula.stem
          end

          where_html = renderer.capture_output do
            if formula.key
              if formula.key.dl
                @output = renderer.capture_output {}
                # "where" label rendered in template, just render the dl
                renderer.render_definition_list(formula.key.dl)
              end
              formula.key.p&.each { |para| renderer.render_paragraph(para) }
            end
            formula.dl&.then { |dl| renderer.render_definition_list(dl) }
          end

          name_el = renderer.safe_attr(formula, :fmt_name) || renderer.safe_attr(formula, :name)
          number_html = if name_el
                          renderer.capture_output { renderer.render_inline_element(name_el) }
                        end

          new(
            id: id,
            stem_html: stem_html,
            where_html: where_html,
            number_html: number_html,
            css_class: "formula",
          )
        end
      end
    end
  end
end
