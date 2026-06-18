# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      class HtmlRenderer
        include HtmlRenderers::StructuralRenderers
        include HtmlRenderers::SectionRenderers
        include HtmlRenderers::BlockRenderers
        include HtmlRenderers::ListRenderers
        include HtmlRenderers::TableRenderers
        include HtmlRenderers::InlineRenderer
        include HtmlRenderers::MarkRenderers

        class << self
          def node_handlers
            @node_handlers ||= {}
          end

          def mark_handlers
            @mark_handlers ||= {}
          end

          def register_node_handler(type, unbound_method)
            node_handlers[type] = unbound_method
          end

          def register_mark_handler(mark_type, handler)
            mark_handlers[mark_type] = handler
          end
        end

        def initialize(guide, numbering: {})
          @content = extract_content(guide)
          @numbering = numbering
        end

        def render
          render_nodes(@content)
        end

        def render_nodes(nodes, depth: 0)
          nodes.filter_map { |node| render_node(node, depth:) }.join("\n")
        end

        def render_node(node, depth: 0)
          case node
          when String
            HtmlRenderers.escape_text(node)
          when Model::Text
            render_text_node(node)
          when Model::Container, Model::Leaf, Model::SoftBreak
            render_typed_node(node, depth:)
          else
            ""
          end
        end

        def render_typed_node(node, depth: 0)
          unbound = self.class.node_handlers[node.type]
          return unbound.bind_call(self, node, depth:) if unbound

          render_generic(node, depth:)
        end

        def render_generic(node, depth: 0)
          children = node.content if node.is_a?(Model::Container)
          return "" unless children && !children.empty?

          render_children(node, depth:)
        end

        def render_children(node, depth: 0)
          children = node.is_a?(Model::Container) ? node.content : []
          render_nodes(children, depth:)
        end

        private

        def extract_content(guide)
          case guide
          when Model::Guide
            guide.content.is_a?(Model::Container) ? guide.content.content : Array(guide.content)
          when Model::Container
            guide.content
          else
            raise ArgumentError, "Unsupported guide type: #{guide.class}"
          end
        end
      end

      HtmlRenderers.register_all(HtmlRenderer)
    end
  end
end
