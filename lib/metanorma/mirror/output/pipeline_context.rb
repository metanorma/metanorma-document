# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      class PipelineContext
        attr_reader :xml_path, :flavor, :title, :id_strategy
        attr_accessor :parsed, :content, :meta

        def initialize(xml_path:, flavor: nil, title: nil, id_strategy: nil)
          @xml_path = xml_path
          @flavor = flavor
          @title = title
          @id_strategy = id_strategy
          @parsed = nil
          @content = nil
          @meta = {}
        end
      end
    end
  end
end
