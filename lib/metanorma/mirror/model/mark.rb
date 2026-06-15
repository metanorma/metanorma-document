# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Mark
        attr_reader :type, :attrs

        def initialize(type:, attrs: {})
          @type = type
          @attrs = normalize_attrs(attrs)
        end

        def to_h
          h = { "type" => type }
          h["attrs"] = @attrs.dup unless @attrs.empty?
          h
        end

        def [](key)
          @attrs[key.to_s]
        end

        def []=(key, value)
          @attrs[key.to_s] = value
        end

        def set_attr(key, value)
          @attrs[key.to_s] = value
          self
        end

        def fetch(key, default = nil, &)
          @attrs.fetch(key.to_s, default, &)
        end

        def self.from_h(hash)
          return nil unless hash

          new(type: hash["type"], attrs: hash["attrs"] || {})
        end

        private

        def normalize_attrs(attrs)
          return {} if attrs.nil?

          attrs.transform_keys(&:to_s)
        end
      end
    end
  end
end
