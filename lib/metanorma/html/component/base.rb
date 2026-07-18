# frozen_string_literal: true

module Metanorma
  module Html
    module Component
      class Base
        include Metanorma::Html::RendererDelegation

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

        def render_mixed_content_in_order(...) = renderer.render_mixed_content_in_order(...)
        def element_attrs(...) = renderer.element_attrs(...)
        def extract_text_value(val) = renderer.extract_text_value(val)

        def self.register_in(registry)
          handled_classes.each do |klass|
            registry.register(klass, self)
          end
        end
      end
    end
  end
end
