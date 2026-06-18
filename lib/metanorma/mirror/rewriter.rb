# frozen_string_literal: true

module Metanorma
  module Mirror
    # Rewrites a mirror Model graph with configurable type-skipping and
    # per-type customization. Despite living in the reverse-conversion
    # namespace, this class produces a Model graph (not Metanorma XML) —
    # the output is a fully model-driven representation that can be
    # serialized via Model#to_h or rendered via Output::HtmlRenderer.
    #
    # Instance API:
    #   Rewriter.new(skip: Set.new(%w[review footnotes]))
    #   rewriter.skip("my_type")
    #   rewriter.register("my_type") { |n, r| ... }
    #
    # Class API (seeds defaults copied into each new instance):
    #   Rewriter.skip("review")        # adds to defaults
    #   Rewriter.register("my_type") { |n, r| ... }
    #
    # Two Rewriter instances do not share state. Class-level mutation only
    # affects instances created afterwards (the default snapshot is copied
    # at `new` time).
    class Rewriter
      DEFAULT_SKIPPED_TYPES = %w[review footnotes].freeze

      class << self
        # Default skip set, copied into each new instance.
        def default_skipped_types
          @default_skipped_types ||= Set.new(DEFAULT_SKIPPED_TYPES)
        end

        # Default builder map, copied into each new instance.
        def default_builders
          @default_builders ||= {}
        end

        # Add a type to the default skip set. Affects instances created
        # afterwards; existing instances are unchanged.
        def skip(type)
          default_skipped_types << type
          self
        end

        # Register a builder for a type at the default level. Affects
        # instances created afterwards; existing instances are unchanged.
        def register(type, &block)
          default_builders[type] = block
          self
        end
      end

      def initialize(skip: nil, builders: nil)
        @skipped_types = skip || self.class.default_skipped_types.dup
        @builders = builders || self.class.default_builders.dup
      end

      attr_reader :skipped_types, :builders

      def skip(type)
        skipped_types << type
        self
      end

      def skipped?(type)
        skipped_types.include?(type)
      end

      def register(type, &block)
        builders[type] = block
        self
      end

      def call(mirror_node)
        build(mirror_node)
      end

      def build(node)
        return nil unless node

        return rewrite_string(node) if node.is_a?(String)

        node.accept_rewriter(self)
      end

      def rewrite_container(node)
        return nil if skipped?(node.type)

        builder = builders[node.type]
        return builder.call(node, self) if builder

        Model::Container.new(
          type: node.type,
          attrs: node.attrs,
          content: build_children(node.content),
        )
      end

      def rewrite_leaf(node)
        return nil if skipped?(node.type)

        Model::Leaf.new(type: node.type, attrs: node.attrs)
      end

      def rewrite_text(node)
        Model::Text.new(text: node.text, marks: node.marks)
      end

      def rewrite_soft_break(_node)
        Model::SoftBreak.new
      end

      def rewrite_string(string)
        Model::Text.new(text: string)
      end

      def build_children(content)
        Array(content).filter_map { |child| build(child) }
      end
    end
  end
end
