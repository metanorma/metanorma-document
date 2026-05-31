# frozen_string_literal: true

require "yaml"

module Metanorma
  module Mirror
    module Serialization
      class YamlSerializer
        def self.serialize(node)
          node.to_h.to_yaml
        end

        def self.deserialize(yaml_string)
          hash = YAML.safe_load(yaml_string)
          Node.from_h(hash)
        end
      end
    end
  end
end
