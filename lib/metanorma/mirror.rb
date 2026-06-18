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
    autoload :MetanormaToMirror, "#{__dir__}/mirror/metanorma_to_mirror"
    autoload :Rewriter, "#{__dir__}/mirror/rewriter"
    autoload :HandlerRegistry, "#{__dir__}/mirror/handler_registry"
    autoload :Handlers, "#{__dir__}/mirror/handlers"
    autoload :IdStrategy, "#{__dir__}/mirror/id_strategy"
    autoload :Output, "#{__dir__}/mirror/output"
    autoload :Serialization, "#{__dir__}/mirror/serialization"
    autoload :DefaultRegistry, "#{__dir__}/mirror/default_registry"

    DEFAULT_ID_STRATEGY = IdStrategy::Preserve.new

    def self.default_registry
      @default_registry ||= build_default_registry
    end

    def self.build_default_registry
      DefaultRegistry.build
    end
  end
end
