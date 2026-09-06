# frozen_string_literal: true

require "json"

module Metanorma
  module Mirror
    module Serialization
      class JsonSerializer
        # Every Model::Node (Leaf included) has a data to_hash; the former
        # Container-only guard serialized bare leaves as inspect strings.
        def self.serialize(node)
          data = node.is_a?(Model::Node) ? node.to_hash : node
          data.to_json
        end

        def self.serialize_pretty(node)
          data = node.is_a?(Model::Node) ? node.to_hash : node
          JSON.pretty_generate(data)
        end

        def self.deserialize(json_string)
          Model::Factory.from_hash(JSON.parse(json_string))
        end
      end
    end
  end
end
