# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      autoload :Pipeline, "#{__dir__}/output/pipeline"
      autoload :PipelineContext, "#{__dir__}/output/pipeline_context"
      autoload :Builder, "#{__dir__}/output/builder"
      autoload :Formats, "#{__dir__}/output/formats"
    end
  end
end
