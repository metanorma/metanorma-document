# frozen_string_literal: true

require "json"

module Metanorma
  module Mirror
    module Serialization
      class JsonSerializer
        def self.serialize(node)
          node.to_h.to_json
        end

        def self.serialize_pretty(node)
          JSON.pretty_generate(node.to_h)
        end

        def self.deserialize(json_string)
          hash = JSON.parse(json_string)
          Node.from_h(hash)
        end
      end
    end
  end
end
