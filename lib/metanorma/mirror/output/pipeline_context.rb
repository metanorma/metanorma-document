# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      PipelineContext = Struct.new(
        :xml_path,
        :flavor,
        :parsed,
        :title,
        :content,
        :id_strategy,
        keyword_init: true,
      )
    end
  end
end
