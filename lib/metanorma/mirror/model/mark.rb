# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Mark < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :attrs, :hash, default: -> { {} }

        key_value do
          map "type", to: :type
          map "attrs", to: :attrs, render_empty: false
        end

        def initialize(type: nil, attrs: {}, **)
          # wire keys are strings; handlers build attrs with symbol keys
          super(type: type, attrs: (attrs || {}).transform_keys(&:to_s), **)
        end

        def [](key)
          attrs[key.to_s]
        end

        def []=(key, value)
          attrs[key.to_s] = value
        end

        def set_attr(key, value)
          attrs[key.to_s] = value
          self
        end

        def fetch(key, default = nil, &)
          attrs.fetch(key.to_s, default, &)
        end
      end
    end
  end
end
