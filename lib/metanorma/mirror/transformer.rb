# frozen_string_literal: true

module Metanorma
  module Mirror
    class Transformer
      def initialize(registry: Mirror.default_registry)
        @registry = registry
      end

      def from_metanorma(root)
        MetanormaToMirror.new(registry: @registry).call(root)
      end

      def to_metanorma(mirror_node)
        MirrorToMetanorma.new.call(mirror_node)
      end
    end
  end
end
