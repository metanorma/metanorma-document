# frozen_string_literal: true

require "json"

module Metanorma
  module Mirror
    module Serialization
      class JsonSerializer
        def self.serialize(data)
          data.to_json
        end

        def self.serialize_pretty(data)
          JSON.pretty_generate(data)
        end

        def self.deserialize(json_string)
          JSON.parse(json_string)
        end
      end
    end
  end
end
