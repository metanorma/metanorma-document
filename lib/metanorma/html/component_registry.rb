# frozen_string_literal: true

module Metanorma
  module Html
    class ComponentRegistry
      def initialize
        @map = {}
      end

      def register(model_class, component_class)
        @map[model_class] = component_class
      end

      def lookup(model_class)
        @map[model_class] ||
          model_class.ancestors
            .drop(1)
            .filter_map { |a| @map[a] }
            .first ||
          nil
      end

      def component_for(renderer, model_class)
        component_class = lookup(model_class)
        component_class&.new(renderer)
      end

      def register_all(component_module)
        component_module.constants.each do |const|
          klass = component_module.const_get(const)
          next unless klass.is_a?(Class) && klass < Component::Base
          klass.register_in(self)
        end
      end
    end
  end
end
