# frozen_string_literal: true

module Metanorma
  module Mirror
    module Serialization
      autoload :JsonSerializer, "#{__dir__}/serialization/json_serializer"
      autoload :YamlSerializer, "#{__dir__}/serialization/yaml_serializer"
    end
  end
end
