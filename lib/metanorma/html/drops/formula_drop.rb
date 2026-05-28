# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class FormulaDrop < BlockElementDrop
        attr_reader :stem_html, :where_html, :where_label, :number_html

        def self.from_model(formula, renderer:)
          id = renderer.safe_attr(formula, :id)

          stem_html = renderer.capture_output do
            renderer.render_stem_content(formula.stem) if formula.stem
          end

          where_html = renderer.capture_output do
            if formula.key
              if formula.key.dl
                @output = renderer.capture_output {}
                renderer.render_definition_list(formula.key.dl)
              end
              formula.key.p&.each { |para| renderer.render_paragraph(para) }
            end
            formula.dl&.then { |dl| renderer.render_definition_list(dl) }
            formula.p&.each do |para|
              text = extract_plain(para)
              next if text.strip == "where"
              renderer.render_paragraph(para)
            end
          end

          needs_where_label = !formula.key.nil? || !formula.dl.nil? ||
                              formula_has_where_p?(formula)

          name_el = renderer.safe_attr(formula,
                                       :fmt_name) || renderer.safe_attr(
                                         formula, :name
                                       )
          number_html = if name_el
                          renderer.capture_output do
                            renderer.render_inline_element(name_el)
                          end
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

          def extract_plain(para)
            return "" unless para
            parts = []
            if para.is_a?(Lutaml::Model::Serializable) && para.mixed?
              para.each_mixed_content do |child|
                case child
                when String then parts << child
                end
              end
            end
            parts.join
          end

          def formula_has_where_p?(formula)
            Array(formula.p).any? do |para|
              extract_plain(para).strip == "where"
            end
          end
        end
      end
    end
  end
end
