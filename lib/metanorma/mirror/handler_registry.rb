# frozen_string_literal: true

module Metanorma
  module Mirror
    class HandlerRegistry
      Entry = Struct.new(:callable, :concat, :extra_kwargs, keyword_init: true)

      def initialize
        @handlers = {}
      end

      def register(model_class, handler, method_name: :call, concat: false,
                   extra_kwargs: {})
        callable = resolve_callable(handler, method_name)
        @handlers[model_class] = Entry.new(
          callable: callable,
          concat: concat,
          extra_kwargs: extra_kwargs,
        )
      end

      def registered?(model_class)
        @handlers.key?(model_class)
      end

      def entry_for(model_element)
        @handlers[model_element.class] || ancestor_entry(model_element)
      end

      def handle(model_element, context:)
        entry = entry_for(model_element)
        return HandlerResult.none unless entry

        kwargs = { context: context }.merge(entry.extra_kwargs || {})
        result = entry.callable.call(model_element, **kwargs)
        HandlerResult.new(result, concat: entry.concat)
      end

      private

      def resolve_callable(handler, method_name)
        return handler if handler.is_a?(Proc)
        return handler.method(:call) if method_name == :call

        handler.method(method_name)
      end

      def ancestor_entry(model_element)
        model_element.class.ancestors.each do |ancestor|
          next if ancestor == model_element.class
          break if ancestor == Object

          entry = @handlers[ancestor]
          return entry if entry
        end
        nil
      end
    end
  end
end
