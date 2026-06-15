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

        # Dispatch table mapping Model classes (and String) to renderer
        # method names. Adding a new Model class = adding one entry here
        # or via register_class — no edits to render_node.
        CLASS_DISPATCH = {
          String => :render_string,
          Model::Text => :render_text_node,
          Model::SoftBreak => :render_soft_break,
          Model::Container => :render_typed_node,
          Model::Leaf => :render_typed_node,
        }.freeze

        class << self
          def node_renderers
            @node_renderers ||= {}
          end

          def custom_node_renderers
            @custom_node_renderers ||= {}
          end

          def custom_mark_renderers
            @custom_mark_renderers ||= {}
          end

          def class_dispatch
            @class_dispatch ||= CLASS_DISPATCH.dup
          end

          def register(type, method_name)
            node_renderers[type] = method_name
          end

          def register_node_renderer(type, handler)
            custom_node_renderers[type] = handler
          end

          def register_mark_renderer(mark_type, handler)
            custom_mark_renderers[mark_type] = handler
          end

          # Register a Model class to a renderer method, allowing new Model
          # types to plug in without modifying render_node.
          def register_class(model_class, method_name)
            class_dispatch[model_class] = method_name
          end
        end

        def initialize(guide, numbering: {})
          content = extract_content(guide)
          @content = content
          @numbering = numbering
        end

        def render
          render_nodes(@content)
        end

        def render_nodes(nodes, depth: 0)
          nodes.filter_map { |node| render_node(node, depth:) }.join("\n")
        end

        def render_node(node, depth: 0)
          method_name = resolve_render_method(node)
          return "" unless method_name

          public_send(method_name, node, depth:)
        end

        def render_string(node, _depth = 0)
          e(node)
        end

        def render_typed_node(node, depth: 0)
          type = node.type

          custom = self.class.custom_node_renderers[type]
          return custom.call(node, self) if custom

          handler = self.class.node_renderers[type]
          return public_send(handler, node, depth:) if handler

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

        def build_id_attr(node)
          id = node.attrs["id"]
          id ? %( id="#{e(id)}") : ""
        end

        def e(text)
          self.class.escape_html(text)
        end

        def self.escape_html(text)
          return "" unless text

          text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub(
            '"', "&quot;"
          )
        end

        def self.escape_attr(text)
          escape_html(text)
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

        def resolve_render_method(node)
          dispatch = self.class.class_dispatch
          return dispatch[node.class] if dispatch.key?(node.class)

          dispatch.each do |klass, method_name|
            return method_name if node.is_a?(klass)
          end
          nil
        end
      end

      HtmlRenderers.register_all(HtmlRenderer)
    end
  end
end
