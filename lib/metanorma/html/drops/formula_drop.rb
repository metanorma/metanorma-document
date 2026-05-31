# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class FormulaDrop < BlockElementDrop
        attr_reader :stem_html, :where_html, :where_label, :number_html

        def initialize(id: nil, stem_html: nil, where_html: nil, where_label: nil,
                       number_html: nil, css_class: nil)
          @id = id
          @stem_html = stem_html
          @where_html = where_html
          @where_label = where_label
          @number_html = number_html
          @css_class = css_class
        end

        def self.from_model(formula, renderer:)
          id = renderer.safe_attr(formula, :id)

          stem_html = if formula.stem
                        renderer.render_stem_content(formula.stem)
                      end

          where_parts = []
          if formula.key
            if formula.key.dl
              where_parts << (renderer.render_definition_list(formula.key.dl) || "")
            end
            formula.key.p&.each { |para| where_parts << (renderer.render_paragraph(para) || "") }
          end
          formula.dl&.then { |dl| where_parts << (renderer.render_definition_list(dl) || "") }
          formula.p&.each do |para|
            next if renderer.safe_attr(para, :keep_with_next)
            where_parts << (renderer.render_paragraph(para) || "")
          end
          where_html = where_parts.join

          needs_where_label = !formula.key.nil? || !formula.dl.nil? ||
                              has_where_paragraph?(formula, renderer)

          name_el = renderer.safe_attr(formula,
                                       :fmt_name) || renderer.safe_attr(
                                         formula, :name
                                       )
          number_html = if name_el
                          renderer.render_inline_element(name_el)
                        end

          new(
            id: id,
            stem_html: stem_html,
            where_html: where_html,
            where_label: needs_where_label,
            number_html: number_html,
            css_class: "formula",
          )
        end

        class << self
          private

          def has_where_paragraph?(formula, renderer)
            Array(formula.p).any? { |para| renderer.safe_attr(para, :keep_with_next) }
          end
        end
      end
    end
  end
end
