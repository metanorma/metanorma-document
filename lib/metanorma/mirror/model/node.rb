# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Node
        attr_reader :type, :attrs

        def initialize(type:, attrs: {})
          @type = type
          @attrs = normalize_attrs(attrs)
        end

        def to_h
          h = { "type" => type }
          h["attrs"] = @attrs.dup unless @attrs.empty?
          h
        end

        def leaf?
          false
        end

        def container?
          false
        end

        def text_content
          ""
        end

        def accept_rewriter(_rewriter)
          raise NotImplementedError, "#{self.class}#accept_rewriter not implemented"
        end

        private

        def normalize_attrs(attrs)
          return {} if attrs.nil?

          attrs.transform_keys(&:to_s)
        end
      end
    end
  end
end
