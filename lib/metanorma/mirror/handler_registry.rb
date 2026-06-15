# frozen_string_literal: true

module Metanorma
  module Mirror
    class HandlerRegistry
      Entry = Struct.new(:handler, :method_name, :concat, :extra_kwargs,
                         keyword_init: true)

      def initialize
        @handlers = {}
      end

      def register(model_class, handler, method_name: :call, concat: false,
                   extra_kwargs: {})
        @handlers[model_class] = Entry.new(
          handler: handler,
          method_name: method_name,
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

        result = case entry.handler
                 when Proc
                   entry.handler.call(model_element, context)
                 else
                   entry.handler.public_send(entry.method_name, model_element,
                                             **kwargs)
                 end

        HandlerResult.new(result, concat: entry.concat)
      end

      private

      def ancestor_entry(model_element)
        model_element.class.ancestors.each do |ancestor|
          next if ancestor == model_element.class
          break if [Lutaml::Model::Serializable, Object].include?(ancestor)

          entry = @handlers[ancestor]
          return entry if entry
        end
        nil
      end
    end
  end
end
