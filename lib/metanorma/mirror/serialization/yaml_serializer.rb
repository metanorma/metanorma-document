# frozen_string_literal: true

require "yaml"

module Metanorma
  module Mirror
    module Serialization
      class YamlSerializer
        def self.serialize(data)
          data.to_yaml
        end

        def self.deserialize(yaml_string)
          YAML.safe_load(yaml_string)
        end
      end
    end
  end
end
