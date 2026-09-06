# frozen_string_literal: true

require "yaml"

module Metanorma
  module Mirror
    module Serialization
      class YamlSerializer
        def self.serialize(node)
          data = node.is_a?(Model::Container) ? node.to_hash : node
          data.to_yaml
        end

        def self.deserialize(yaml_string)
          Model::Factory.from_hash(YAML.safe_load(yaml_string))
        end
      end
    end
  end
end
