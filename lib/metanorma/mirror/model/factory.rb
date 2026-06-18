# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Factory
        INVALID_INPUT = "Factory.from_h expects a Hash, got %<class>s"

        def self.from_h(hash)
          unless hash.is_a?(Hash)
            raise ArgumentError,
                  format(INVALID_INPUT, class: hash.class)
          end

          type = hash["type"]

          case type
          when "text"
            build_text(hash)
          when "soft_break"
            SoftBreak.new
          when nil
            raise ArgumentError,
                  "Factory.from_h requires a 'type' key, got #{hash.inspect}"
          else
            build_node(hash, type)
          end
        end

        class << self
          private

          def build_text(hash)
            marks = Array(hash["marks"]).map { |m| Mark.from_h(m) }
            Text.new(text: hash["text"] || "", marks: marks)
          end

          def build_node(hash, type)
            content = hash["content"]
            if content.is_a?(Array)
              children = content.map { |c| c.is_a?(Hash) ? from_h(c) : c }
              Container.new(type: type, attrs: hash["attrs"] || {},
                            content: children)
            else
              Leaf.new(type: type, attrs: hash["attrs"] || {})
            end
          end
        end
      end
    end
  end
end
