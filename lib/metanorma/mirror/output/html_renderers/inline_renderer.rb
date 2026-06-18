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

            HtmlRenderers.build_fragment do |doc|
              content.each do |node|
                case node
                when String
                  doc.text node
                when Model::Text
                  HtmlRenderers.embed(doc, render_text_node(node))
                when Model::SoftBreak
                  doc.br
                when Model::Container
                  if node.type == "footnote_marker"
                    HtmlRenderers.embed(doc, render_footnote_marker(node))
                  else
                    HtmlRenderers.embed(doc, render_node(node))
                  end
                end
              end
            end
          end

          def render_text_node(node)
            inner_html = HtmlRenderers.escape_text(node.text)
            node.marks.reduce(inner_html) { |current, mark| apply_mark(current, mark) }
          end

          def apply_mark(inner_html, mark)
            handler = self.class.mark_handlers[mark.type]
            handler ? handler.call(inner_html, mark) : inner_html
          end

          def render_footnote_marker(node)
            HtmlRenderers.build do |doc|
              doc.sup(class: "footnote-marker") do
                attrs = {}
                attrs[:id] = node.attrs["id"] if node.attrs["id"]
                doc.a(attrs.merge(href: "##{node.attrs['ref_id'] || ''}")) do
                  doc.text node.attrs["number"] || "*"
                end
              end
            end
          end
        end
      end
    end
  end
end
