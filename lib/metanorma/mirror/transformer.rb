# frozen_string_literal: true

module Metanorma
  module Mirror
    class Transformer
      def initialize(registry: Mirror.default_registry, id_strategy: Mirror::DEFAULT_ID_STRATEGY)
        @registry = registry
        @id_strategy = id_strategy
      end

      def from_metanorma(root)
        document = MetanormaToMirror.new(registry: @registry,
                                         id_strategy: @id_strategy).call(root)
        @id_strategy.finalize!(document)
      end

      def rewrite(mirror_node)
        Rewriter.new.call(mirror_node)
      end
    end
  end
end
