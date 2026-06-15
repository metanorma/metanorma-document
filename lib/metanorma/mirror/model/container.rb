# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Container < Node
        attr_reader :content

        def initialize(type:, attrs: {}, content: [])
          super(type: type, attrs: attrs)
          @content = Array(content)
        end

        def container?
          true
        end

        def to_h
          h = super
          unless @content.empty?
            h["content"] = @content.map { |c| serialize_child(c) }
          end
          h
        end

        def text_content
          @content.filter_map do |item|
            case item
            when Text then item.text
            when Container then item.text_content
            end
          end.join
        end

        private

        def serialize_child(child)
          case child
          when String then child
          else child.to_h
          end
        end
      end
    end
  end
end
