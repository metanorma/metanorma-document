# frozen_string_literal: true

module Metanorma
  module Mirror
    # Reverse converter: takes a mirror Model graph and rebuilds it with
    # configurable type-skipping and per-type customization.
    #
    # Despite the name (kept for backward compatibility with the public
    # Transformer API), this class produces a Model graph, not Metanorma
    # XML. The output is a fully model-driven representation that can be
    # serialized via Model#to_h or rendered via Output::HtmlRenderer.
    #
    # Adding a new behavior:
    #   - To skip a new type:  MirrorToMetanorma.skip("my_type")
    #   - To customize a type: MirrorToMetanorma.register("my_type") { |n, ctx| ... }
    #
    # No edits to dispatch code required (OCP).
    class MirrorToMetanorma
      @skipped_types = Set.new
      @builders = {}

      class << self
        attr_reader :skipped_types, :builders

        def skip(type)
          skipped_types << type
          self
        end

        def register(type, &block)
          builders[type] = block
          self
        end

        def skipped?(type)
          skipped_types.include?(type)
        end
      end

      skip("review")
      skip("footnotes")

      def call(mirror_node)
        build(mirror_node)
      end

      def build(node)
        return nil unless node

        case node
        when Model::Text then build_text(node)
        when Model::SoftBreak then Model::SoftBreak.new
        when Model::Container then build_container(node)
        when Model::Leaf then build_leaf(node)
        when String then Model::Text.new(text: node)
        end
      end

      def build_container(node)
        return nil if self.class.skipped?(node.type)

        builder = self.class.builders[node.type]
        return builder.call(node, self) if builder

        Model::Container.new(
          type: node.type,
          attrs: node.attrs,
          content: build_children(node.content),
        )
      end

      def build_leaf(node)
        return nil if self.class.skipped?(node.type)

        Model::Leaf.new(type: node.type, attrs: node.attrs)
      end

      def build_children(content)
        Array(content).filter_map { |child| build(child) }
      end

      def build_text(node)
        Model::Text.new(text: node.text, marks: node.marks)
      end
    end
  end
end
