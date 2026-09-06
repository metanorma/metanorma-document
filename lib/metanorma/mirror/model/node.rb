# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Node < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :attrs, :hash, default: -> { {} }

        key_value do
          map "type", to: :type
          map "attrs", to: :attrs, render_empty: false
        end

        # **options carries framework construction kwargs
        # (e.g. lutaml_register) through to the base serializer
        def initialize(type: nil, attrs: {}, **)
          # wire keys are strings; handlers and the transformer build
          # attrs with symbol keys
          super(type: type, attrs: (attrs || {}).transform_keys(&:to_s), **)
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
          raise NotImplementedError,
                "#{self.class}#accept_rewriter not implemented"
        end
      end
    end
  end
end
