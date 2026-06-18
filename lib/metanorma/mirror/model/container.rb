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
          @content.map { |item| item.is_a?(String) ? item : item.text_content }.join
        end

        def accept_rewriter(rewriter)
          rewriter.rewrite_container(self)
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
