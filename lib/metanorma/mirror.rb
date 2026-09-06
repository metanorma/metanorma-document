# frozen_string_literal: true

module Metanorma
  module Mirror
    class Error < StandardError; end

    autoload :SafeAttr, "#{__dir__}/mirror/safe_attr"
    autoload :MathUtil, "#{__dir__}/mirror/math_util"
    autoload :Metadata, "#{__dir__}/mirror/metadata"
    autoload :Model, "#{__dir__}/mirror/model"
    autoload :HandlerResult, "#{__dir__}/mirror/handler_result"
    autoload :Transformer, "#{__dir__}/mirror/transformer"
    autoload :Rewriter, "#{__dir__}/mirror/rewriter"
    autoload :HandlerRegistry, "#{__dir__}/mirror/handler_registry"
    autoload :Handlers, "#{__dir__}/mirror/handlers"
    autoload :IdStrategy, "#{__dir__}/mirror/id_strategy"
    autoload :Output, "#{__dir__}/mirror/output"
    autoload :Serialization, "#{__dir__}/mirror/serialization"
    autoload :DefaultRegistry, "#{__dir__}/mirror/default_registry"

    DEFAULT_ID_STRATEGY = IdStrategy::Preserve.new

    # Pre-build registration seam: flavor gems add handler entries to
    # the default registry via blocks, run in registration order during
    # build. Keeps the harness free of flavor knowledge while default
    # consumers (CLI JSON export) see the complete registry.
    @default_hooks = []

    def self.register_default(&block)
      @default_hooks << block
    end

    def self.default_hooks
      @default_hooks
    end

    def self.default_registry
      @default_registry ||= build_default_registry
    end

    def self.build_default_registry
      DefaultRegistry.build
    end
  end
end
