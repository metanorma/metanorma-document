# frozen_string_literal: true

require "json"

module Metanorma
  module Mirror
    module Serialization
      class JsonSerializer
        def self.serialize(node)
          data = node.is_a?(Model::Container) ? node.to_h : node
          data.to_json
        end

        def self.serialize_pretty(node)
          data = node.is_a?(Model::Container) ? node.to_h : node
          JSON.pretty_generate(data)
        end

        def self.deserialize(json_string)
          Model::Factory.from_h(JSON.parse(json_string))
        end
      end
    end
  end
end
