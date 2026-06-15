# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module InlineRenderer
          def self.register(registry); end

          def render_inline(content)
            return "" unless content
            return "" if content.empty?

            content.filter_map do |node|
              case node
              when String
                e(node)
              when Model::Text
                render_text_node(node)
              when Model::SoftBreak
                "<br />"
              when Model::Container
                if node.type == "footnote_marker"
                  render_footnote_marker(node)
                else
                  render_node(node)
                end
              else
                ""
              end
            end.join
          end

          def render_text_node(node)
            text = e(node.text)
            node.marks.reduce(text) { |current, mark| apply_mark(current, mark) }
          end

          def apply_mark(text, mark)
            mark_type = mark.type

            custom = self.class.custom_mark_renderers[mark_type]
            return custom.call(text, mark) if custom

            handler = MarkRenderers::MARK_RENDERERS[mark_type]
            return handler.call(text, mark) if handler

            text
          end

          def render_footnote_marker(node)
            id = node.attrs["id"]
            ref_id = node.attrs["ref_id"]
            id_attr = id ? %( id="#{e(id)}") : ""
            %(<sup class="footnote-marker"><a#{id_attr} href="##{e(ref_id || '')}">#{e(node.attrs['number'] || '*')}</a></sup>)
          end
        end
      end
    end
  end
end
