# frozen_string_literal: true

module Metanorma
  module Html
    module Component
      class Base
        attr_reader :renderer

        def initialize(renderer)
          @renderer = renderer
        end

        def self.handles(*model_classes)
          @handled_classes = model_classes
        end

        def self.handled_classes
          @handled_classes || []
        end

        def self.requires_css(*names)
          @css_deps = names
        end

        def self.css_dependencies
          @css_deps || []
        end

        def self.requires_js(*names)
          @js_deps = names
        end

        def self.js_dependencies
          @js_deps || []
        end

        def render(node, **opts)
          raise NotImplementedError, "#{self.class}#render not implemented"
        end

        def output
          renderer.instance_variable_get(:@output)
        end

        def tag(...) = renderer.tag(...)
        def escape_html(...) = renderer.escape_html(...)
        def render_mixed_inline(...) = renderer.render_mixed_inline(...)
        def render_mixed_content_in_order(...) = renderer.render_mixed_content_in_order(...)
        def element_attrs(...) = renderer.element_attrs(...)
        def safe_attr(obj, method_name) = renderer.safe_attr(obj, method_name)
        def extract_plain_text(node) = renderer.extract_plain_text(node)
        def extract_text_value(val) = renderer.extract_text_value(val)
        def extract_block_label(block, default) = renderer.extract_block_label(block, default)

        def self.register_in(registry)
          handled_classes.each do |klass|
            registry.register(klass, self)
          end
        end
      end
    end
  end
end
