# frozen_string_literal: true

module Metanorma
  module Mirror
    class MirrorToMetanorma
      INLINE_TYPES = %w[paragraph table_cell dt].freeze
      LEAF_TYPES = %w[image sourcecode formula floating_title].freeze
      SKIPPED_TYPES = %w[review footnotes].freeze

      def call(mirror_node)
        node = mirror_node.is_a?(Hash) ? mirror_node : mirror_node.to_h
        build(node)
      end

      def build(node)
        return nil unless node.is_a?(Hash)

        type = node["type"]
        return nil if SKIPPED_TYPES.include?(type)

        custom = self.class.custom_builders[type]
        return custom.call(node, self) if custom

        if type == "text"
          build_text(node)
        elsif type == "soft_break"
          { type: "soft_break" }
        elsif LEAF_TYPES.include?(type)
          { type: type, attrs: stringify_attrs(node) }
        elsif INLINE_TYPES.include?(type)
          { type: type, attrs: stringify_attrs(node),
            content: build_inline(node["content"]) }
        else
          { type: type, attrs: stringify_attrs(node),
            content: build_children(node["content"]) }
        end
      end

      def build_children(content)
        Array(content).filter_map { |child| build(child) }
      end

      def build_inline(content)
        Array(content).filter_map do |child|
          next { type: "text", text: child } if child.is_a?(String)
          next build(child) if child.is_a?(Hash)
        end
      end

      def build_text(node)
        result = { type: "text", text: node["text"].to_s }
        marks = node["marks"]
        result[:marks] = marks.map { |m| m.is_a?(Hash) ? m : m.to_h } if marks && !marks.empty?
        result
      end

      def stringify_attrs(node)
        (node["attrs"] || {}).transform_keys(&:to_s)
      end

      class << self
        def custom_builders
          @custom_builders ||= {}
        end

        def register_builder(type, handler)
          custom_builders[type] = handler
        end
      end
    end
  end
end
